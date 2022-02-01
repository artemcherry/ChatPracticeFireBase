//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase
class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()// Создаем ссылку на баззу данных
    
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        title = K.appName
        navigationItem.hidesBackButton = true // Скрывает кнопку назад в Navigation Bar
        
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier) // Чтобы пользоваться кастомной ячейкой мы должны ее зарегестрировать
        
        loadMessages()
    }
    // Метод загрузки сообщений и базы данных
    func loadMessages() {
        
        // Ниже показан метод для единовременного получения данных .getDocuments, но чтобы метод loadMessages получал обновления в реальном времени и выполнялся каждый раз после того как отправлялось новое сообщение нужно ставить .addSnapshotListner
        // Так же добавляем вариант сортировка сообщений с помощью .order
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener{ querySnapshot, error in
            self.messages = []
            
            if let e = error{
                print("There is some problen of loading data error \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for docs in snapshotDocuments {
                        let data = docs.data()
                        if let messageSender = data[K.FStore.senderField] as? String, let messageBody = data[K.FStore.bodyField] as? String {
                            let newMessage = Message(sender: messageSender, body: messageBody)
                            
                            self.messages.append(newMessage)
                            
                            DispatchQueue.main.async { // выполняем обновление контроллера в галвном потоке
                                self.tableView.reloadData() // Чтобы загурзить данные на контроллер
                                    // При открытии чтобы  чата наша таблица сьехжала вниз делаем следуйщее
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    @IBAction func sendPressed(_ sender: UIButton) {
       
        // Здесь будут инстукции по отправке сообщений в базу данных
        if let messageBody = messageTextfield.text,
            let messageSender = Auth.auth().currentUser?.email{
           
            db.collection(K.FStore.collectionName).addDocument(data: [K.FStore.senderField : messageSender, K.FStore.bodyField : messageBody, K.FStore.dateField : Date().timeIntervalSince1970]) { error in
                if let e = error{
                    print("Oops something went wrong with \(e)")
                } else {
                    print("Data has uploded succesfuly")
                    DispatchQueue.main.async {
                        self.messageTextfield.text = ""
                    }
                }
            }
        }
    }
    
    @IBAction func logutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)// перекидывает на начальный экран
            
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
extension ChatViewController: UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = message.body
        // Кастомизация ячеек при отправке сообщений и получения сообщений
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: K.BrandColors.purple)
        } else {
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
        }
        
        
        return cell
    }
    
    
    
}
