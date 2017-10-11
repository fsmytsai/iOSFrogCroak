//
//  MessageViewController.swift
//  FrogCroak
//
//  Created by 蔡旻袁 on 2017/10/8.
//  Copyright © 2017年 蔡旻袁. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var tf_Message: UITextField!
    @IBOutlet weak var table_Message: UITableView!
    
    private var isKeyboardShown = false
    private var keyboardHeight: CGFloat = 0
    private var messageView = MessageView(MessageList: [MessageView.Message]())
    
    private var l_MessageMaxWidth: CGFloat = 0
    
    var db: OpaquePointer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setPushFrameAndTapCloseKB()
        
        openDatabase()
        
        //讀取訊息
        readMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (self.table_Message.contentSize.height > self.table_Message.frame.height)
        {
            table_Message.scrollToRow(at: IndexPath(row: messageView.MessageList.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
        }
    }
    
    func setPushFrameAndTapCloseKB(){
        //監控開啟關閉鍵盤
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow(note:)),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide(note:)),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil)
        
        
        //監控點擊畫面
        let singleFinger = UITapGestureRecognizer(
            target: self,
            action: #selector(self.tapTableView(_:)))
        
        // 點幾下才觸發 設置 2 時 則是要點兩下才會觸發 依此類推
        singleFinger.numberOfTapsRequired = 1
        
        // 幾根指頭觸發
        singleFinger.numberOfTouchesRequired = 1
        
        // 為視圖加入監聽手勢
        self.view.addGestureRecognizer(singleFinger)
    }
    
    func openDatabase() {
        // 資料庫檔案的路徑
        let urls = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask)
        
        let sqlitePath = urls[urls.count-1].absoluteString + "sqlite3.db"
        if sqlite3_open(sqlitePath, &db) == SQLITE_OK {
            print("Successfully opened connection to database at \(sqlitePath)")
            //資料庫開啟成功則新建資料表
            createTable()
        } else {
            print("Unable to open database. Verify that you created the directory described " +
                "in the Getting Started section.")
        }
    }
    
    func createTable() {
        let createTableString = """
        create table if not exists messages(
        _id INTEGER PRIMARY KEY NOT NULL,
        message TEXT NOT NULL,
        isme INTEGER NOT NULL,
        type INTEGER NOT NULL)
        """
        
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("message table created.")
            } else {
                print("message table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
    
    func insertMessage(message: String, isme: Int32, type: Int32){
        let insertStatementString = "insert into messages (message, isme, type) values (?, ?, ?);"
        var insertStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(insertStatement, 1, message, -1, nil)
            sqlite3_bind_int(insertStatement, 2, isme)
            sqlite3_bind_int(insertStatement, 3, type)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        
        sqlite3_finalize(insertStatement)
    }
    
    func readMessages() {
        let queryStatementString = "SELECT * FROM messages;"
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                let messageQueryResult = sqlite3_column_text(queryStatement, 1)
                let message = String(cString: messageQueryResult!)
                let isme = sqlite3_column_int(queryStatement, 2)
                let type = sqlite3_column_int(queryStatement, 3)
                let messageStruct = MessageView.Message(message: message, isme: isme == 1, type: Int(type))
                messageView.MessageList.append(messageStruct)
            }
            
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
    }
    
    @IBAction func bt_SendMessage(_ sender: UIButton) {
        sendMessage()
    }
    
    func sendMessage() {
        if tf_Message.text! != "" {
            insertMessage(message: tf_Message.text!, isme: 1, type: 0)
            
            let messageStruct = MessageView.Message(message: tf_Message.text!, isme: true, type: 0)
            messageView.MessageList.append(messageStruct)
            table_Message.beginUpdates()
            table_Message.insertRows(at: [IndexPath(row: messageView.MessageList.count - 1, section: 0)], with: .automatic)
            table_Message.endUpdates()
            
            table_Message.scrollToRow(at: IndexPath(row: messageView.MessageList.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
            
            tf_Message.resignFirstResponder()
            tf_Message.text = ""
        }
    }
    
    @objc func keyboardWillShow(note: NSNotification) {
        if isKeyboardShown {
            return
        }
        
        let keyboardAnimationDetail = note.userInfo as! [String: AnyObject]
        let duration = TimeInterval(truncating: keyboardAnimationDetail[UIKeyboardAnimationDurationUserInfoKey]! as! NSNumber)
        let keyboardFrameValue = keyboardAnimationDetail[UIKeyboardFrameBeginUserInfoKey]! as! NSValue
        let keyboardFrame = keyboardFrameValue.cgRectValue
        if keyboardFrame.size.height != 0 {
            keyboardHeight = keyboardFrame.size.height
        }
        UIView.animate(withDuration: duration, animations: {
            () -> Void in
            self.parent?.view.frame = (self.parent?.view.frame.offsetBy(dx: 0, dy: -self.keyboardHeight))!
        })
        isKeyboardShown = true
    }
    
    @objc func keyboardWillHide(note: NSNotification) {
        let keyboardAnimationDetail = note.userInfo as! [String: AnyObject]
        let duration = TimeInterval(truncating: keyboardAnimationDetail[UIKeyboardAnimationDurationUserInfoKey]! as! NSNumber)
        UIView.animate(withDuration: duration, animations: {
            () -> Void in
            self.parent?.view.frame =  (self.parent?.view.frame.offsetBy(dx: 0, dy: self.keyboardHeight))!
        })
        isKeyboardShown = false
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageView.MessageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        let l_Message: PaddingLabel
        
        if messageView.MessageList[indexPath.row].isme {
            cell = tableView.dequeueReusableCell(withIdentifier: "Right", for: indexPath)
            l_Message = cell.contentView.subviews[0] as! PaddingLabel
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "Left", for: indexPath)
            l_Message = cell.contentView.subviews[2] as! PaddingLabel
        }
        
        l_Message.text = messageView.MessageList[indexPath.row].message
        print(l_Message.text!)
        
        if l_MessageMaxWidth == 0 {
            l_MessageMaxWidth = tableView.frame.size.width * 0.7 - 40
        }
        
        l_Message.translatesAutoresizingMaskIntoConstraints = true
        
        let rect = l_Message.text!.boundingRect(with: CGSize(width: l_MessageMaxWidth, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [.font: l_Message.font], context: nil)
        
        l_Message.frame.size.height = rect.height + 40
        
        if rect.width < l_MessageMaxWidth - 50 {
            l_Message.frame.size.width = rect.width + 42
            if messageView.MessageList[indexPath.row].isme {
                l_Message.frame.origin.x = tableView.frame.width - rect.width - 52
            } else {
                l_Message.frame.origin.x = cell.contentView.subviews[0].frame.width + 20
            }
        }
        
        l_Message.layer.cornerRadius = 20
        l_Message.layer.masksToBounds = true
        

        return cell
    }
    
    @objc func tapTableView(_ recognizer: UITapGestureRecognizer){
        tf_Message.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
}
