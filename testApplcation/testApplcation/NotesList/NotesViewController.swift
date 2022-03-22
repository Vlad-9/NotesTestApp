//
//  NotesViewController.swift
//  testApplcation
//
//  Created by Влад on 20.03.2022.
//

import UIKit

protocol INotesViewController: AnyObject {
    func update(_ notes: [Note])
    func openNoteEditingScreen(with note: Note)
    func showAlert(with error: Error)
}


final class NotesViewController: UIViewController {

    // MARK: - Properties

    var pinnedNotes: [Note] {
        presenter.notes.filter { $0.pinned == true }.sorted { $0.date > $1.date }
    }

    var nonPinnedNotes: [Note] {
        presenter.notes.filter { $0.pinned == false }.sorted { $0.date > $1.date }
    }

    // MARK: - Dependencies

    private let presenter: INotesPresenter
    private let noteEditingAssembly: INoteEditingAssembly = NoteEditingAssembly()

    // MARK: - UI Elements

    private lazy var tableView: UITableView = {
        var tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(NoteTableViewCell.self, forCellReuseIdentifier: "cellId")
        return tableView
    }()

    private lazy var createNoteBarItem = UIBarButtonItem(
        image: UIImage(systemName: "square.and.pencil"),
        style: .plain,
        target: self,
        action: #selector(userDidRequestCreateNewNote)
    )

    // MARK: - Initializers

    init(presenter: INotesPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private
    
    private func setupUI() {

        createNoteBarItem.tintColor = .customColor
        navigationItem.rightBarButtonItem = createNoteBarItem
        navigationItem.backButtonTitle = "Заметки"
        navigationController!.navigationBar.tintColor = .customColor
        navigationController!.navigationBar.barTintColor = .systemGray6
        navigationController!.navigationBar.shadowImage = UIImage()

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    @objc private func userDidRequestCreateNewNote() {
        presenter.userDidRequestCreate()
    }

    private func handlePin(indexPath: IndexPath) {
        if indexPath.section == 0 && tableView.numberOfSections != 1 {
            presenter.userDidPin(pinnedNotes[indexPath.row])
        } else {
            presenter.userDidPin(nonPinnedNotes[indexPath.row])
        }
    }

    private func handleDelete(indexPath: IndexPath) {
        if indexPath.section == 0 && tableView.numberOfSections != 1 {

            presenter.userDidDelete(pinnedNotes[indexPath.row])
        } else {

            presenter.userDidDelete(nonPinnedNotes[indexPath.row])
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()
        presenter.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor.systemGray6

        presenter.viewDidLoad()
    }
}

// MARK: - INotesViewController

extension NotesViewController: INotesViewController {
    func update(_ notes: [Note]) {
        tableView.reloadData()
    }

    func openNoteEditingScreen(with note: Note) {
        navigationController?.pushViewController(
            noteEditingAssembly.createNoteEditingViewController(
                note: note
            ) { [weak self] updatedNote in
                self?.presenter.userDidUpdate(updatedNote)
            },
            animated: true
        )
    }

    func showAlert(with error: Error) {
        print ("Error")
    }
}

// MARK: - UITableViewDataSource


extension NotesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView

        if let textlabel = header.textLabel {
            textlabel.font = .boldSystemFont(ofSize: 24)
            textlabel.textColor = .customColor

        }

        header.textLabel?.text = self.tableView(tableView, titleForHeaderInSection: section)

    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {


        if tableView.numberOfSections == 1 || nonPinnedNotes.count != 0 && section == 1 {
            return "Заметки"
        } else if section == 0 {
            return "Закреплено"
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! NoteTableViewCell

        if indexPath.section == 0 && tableView.numberOfSections != 1 {

            let thisNote = pinnedNotes[indexPath.row]
            var pinnedCell = CellModel(
                title: thisNote.title,
                text:  thisNote.text,
                date: thisNote.date,
                image: UIImage()
            )
            if  let imageFromText = presenter.getImage(atSring: thisNote.text ?? NSAttributedString()) {
                pinnedCell.image = imageFromText
            }
            cell.configure(model: pinnedCell)
            return cell

        } else {

            let thisNote = nonPinnedNotes[indexPath.row]

            var NonPinnedCell = CellModel(
                title: thisNote.title,
                text:  thisNote.text,
                date: thisNote.date,
                image: UIImage()
            )
            if  let imageFromText = presenter.getImage(atSring: thisNote.text ?? NSAttributedString()) {
                NonPinnedCell.image = imageFromText
            }
            cell.configure(model: NonPinnedCell)
            return cell
        }

    }

    func numberOfSections(in tableView: UITableView) -> Int {

        pinnedNotes.count != 0 ? 2 : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0 && tableView.numberOfSections != 1 {
            return  pinnedNotes.count
        } else {
            return nonPinnedNotes.count
        }
    }
}

// MARK: - UITableViewDelegate

extension NotesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.section == 0 && tableView.numberOfSections != 1 {

            let selectedNote =
            pinnedNotes[indexPath.row]
            presenter.userDidSelect(selectedNote)
        } else {
            let selectedNote =
            nonPinnedNotes[indexPath.row]
            presenter.userDidSelect(selectedNote)

        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            self.handleDelete(indexPath: indexPath)
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }

    func tableView(
        _ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let title = ""
        let action = UIContextualAction(
            style: .normal,
            title: title
        )
        { [weak self] action, view, completionHandler in
            self?.handlePin(indexPath: indexPath)
            completionHandler(true)
        }
        if indexPath.section == 0 && tableView.numberOfSections != 1 {
            action.image = UIImage(systemName: "pin.slash.fill")
        } else {
            action.image = UIImage(systemName: "pin.fill")
        }
        action.backgroundColor = .systemOrange
        return UISwipeActionsConfiguration(actions: [action])
    }
}
