//
//  MessageViewController.swift
//  FrogCroak
//
//  Created by 蔡旻袁 on 2017/10/8.
//  Copyright © 2017年 蔡旻袁. All rights reserved.
//

import UIKit
import Alamofire
import Photos

class MessageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tf_Message: UITextField!
    @IBOutlet weak var table_Message: UITableView!
    
    private var isKeyboardShown = false
    private var keyboardHeight: CGFloat = 0
    private var messageArr = [Message]()
    
    private var contentMaxWidth: CGFloat = 0
    private var rawValueDictionary = [String:CGFloat]()
    private var imageCache = NSCache<AnyObject, AnyObject>()
    
    private var db: OpaquePointer? = nil
    private var nowPage: Int = 0
    
    private var isLoading = false
    private var isFinishLoad = false
    
    private var newMessageCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table_Message.transform = CGAffineTransform(rotationAngle: -.pi)
        contentMaxWidth = view.frame.width * 0.7
        setPushFrameAndTapCloseKB()
        
        openDatabase()
        
        //讀取訊息
        readMessages()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        if (self.table_Message.contentSize.height > self.table_Message.frame.height)
//        {
//            table_Message.scrollToRow(at: IndexPath(row: messageArr.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
//        }
//    }
    
    func setPushFrameAndTapCloseKB(){
        //監控開啟鍵盤
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow(note:)),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil)
        
        //監控關閉鍵盤
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide(note:)),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil)
        
        
        //監控點擊畫面
        let singleFinger = UITapGestureRecognizer(
            target: self,
            action: #selector(self.tapTableView(_:)))
        
        //點1下觸發
        singleFinger.numberOfTapsRequired = 1
        
        //一根手指觸發
        singleFinger.numberOfTouchesRequired = 1
        
        //為視圖加入監聽手勢
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
            print("Unable to open database. Verify that you created the directory described")
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
                newMessageCount += 1
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
        let queryStatementString = "SELECT * FROM messages ORDER BY _id DESC LIMIT \(nowPage * 10 + newMessageCount),10 ;"
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            nowPage += 1
            var loadTimes = 0
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                let messageQueryResult = sqlite3_column_text(queryStatement, 1)
                let message = String(cString: messageQueryResult!)
                let isme = sqlite3_column_int(queryStatement, 2)
                let type = sqlite3_column_int(queryStatement, 3)
                let messageStruct = Message(message: message, isme: isme == 1, type: Int(type))
                messageArr.append(messageStruct)
                loadTimes += 1
            }
            
            print("messageArr=\(messageArr)")
            
            if isLoading {
                table_Message.reloadData()
                isLoading = false
            }
            
            if loadTimes < 10 {
                isFinishLoad = true
            }
            
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
    }
    
    
    @IBAction func bt_SelectImage(_ sender: UIButton) {
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    self.openImagePickerController()
                } else if status == .denied || status == .restricted {
                    SharedService.ShowErrorDialog("無權限開啟相簿，請至設定內修改隱私權限", self)
                }
            })
        } else if PHPhotoLibrary.authorizationStatus() == .authorized {
            openImagePickerController()
        } else {
            SharedService.ShowErrorDialog("無權限開啟相簿，請至設定內修改隱私權限", self)
        }
    }
    
    func openImagePickerController() {
        let ImagePicker = UIImagePickerController()
        ImagePicker.sourceType = .photoLibrary
        ImagePicker.delegate = self
        present(ImagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //從info拿到照下的圖片
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let docUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let interval = Date.timeIntervalSinceReferenceDate
        let name = "\(interval).jpg"
        let url = docUrl.appendingPathComponent(name)
        
        //把圖片存在APP裡
        var Quality: CGFloat = 1.0
        var data = UIImageJPEGRepresentation(selectedImage, Quality)!
        while data.count / 1024 > 250 && Quality > 0.1 {
            Quality -= 0.1
            data = UIImageJPEGRepresentation(selectedImage, Quality)!
        }
        try! data.write(to: url)
        
        dismiss(animated: true, completion: nil)
        
        insertMessage(message: name, isme: 1, type: 1)
        let messageStruct = Message(message: name, isme: true, type: 1)
        self.messageArr.insert(messageStruct, at: 0)
        updateTableViewRow()
        
        //使用Alamofire上传
        Alamofire.upload(
            multipartFormData: {
                multipartFormData in
                multipartFormData.append(url, withName: "file[0]", fileName: name, mimeType: "image/jpeg")
        },
            to: "https://frogcroak.azurewebsites.net/api/ImageApi/UploadImage",
            headers: ["content-type":"multipart/form-data"],
            encodingCompletion: {
                encodingResult in
                switch encodingResult {
                case .success(let upload, _, _) :
                    upload.responseJSON {
                        response in
                        self.insertMessage(message: response.result.value! as! String, isme: 0, type: 0)
                        
                        DispatchQueue.main.async {
                            let messageStruct = Message(message: response.result.value! as! String, isme: false, type: 0)
                            self.messageArr.insert(messageStruct, at: 0)
                            self.updateTableViewRow()
                        }
                    }
                    break
                case .failure(let encodingError) :
                    print(encodingError)
                    break
                }
        })
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func bt_SendMessage(_ sender: UIButton) {
        sendMessage()
    }
    
    func sendMessage() {
        if let Content = tf_Message.text, Content != "" {
            tf_Message.resignFirstResponder()
            tf_Message.text = ""
            
            insertMessage(message: Content, isme: 1, type: 0)
            let messageStruct = Message(message: Content, isme: true, type: 0)
            messageArr.insert(messageStruct, at: 0)
            updateTableViewRow()
            
            var request = URLRequest(url: URL(string: "https://frogcroak.azurewebsites.net/api/MessageApi/CreateMessage")!)
            request.httpMethod = "POST"
            let postString = "Content=\(Content)"
            request.httpBody = postString.data(using: .utf8)
            URLSession.shared.dataTask(with: request, completionHandler: {
                (data: Data?, response: URLResponse?, error: Error?) in
                if error != nil {
                    print("發生錯誤：\(error!.localizedDescription)")
                    return
                }
                
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        var result = String(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
                        
                        let start = result.index(result.startIndex, offsetBy: 1)
                        let end = result.index(result.endIndex, offsetBy: -1)
                        result = String(result[start..<end])
                        result = result.replacingOccurrences(of: "\\\\n", with: "\n")
                        self.insertMessage(message: result, isme: 0, type: 0)
                        
                        DispatchQueue.main.async {
                            let messageStruct = Message(message: result, isme: false, type: 0)
                            self.messageArr.insert(messageStruct, at: 0)
                            self.updateTableViewRow()
                        }
                        
                    } else {
                        print("response.statusCode = \(response.statusCode)")
                    }
                    
                } else {
                    print("response 解析失敗")
                }
                
            }).resume()
        }
    }
    
    func updateTableViewRow() {
        table_Message.beginUpdates()
        table_Message.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        table_Message.endUpdates()
        
        table_Message.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
    }
    
    @objc func keyboardWillShow(note: NSNotification) {
        if isKeyboardShown {
            return
        }
        
        let keyboardAnimationDetail = note.userInfo as! [String: AnyObject]
        print(keyboardAnimationDetail[UIKeyboardAnimationDurationUserInfoKey]!)
        let duration = TimeInterval(truncating: keyboardAnimationDetail[UIKeyboardAnimationDurationUserInfoKey]! as! NSNumber)
        print(duration)
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
        return messageArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if messageArr[indexPath.row].type == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "MyImage", for: indexPath)
            cell.transform = CGAffineTransform(rotationAngle: -.pi)
            
            let iv_MyImageView = cell.contentView.subviews[0] as! UIImageView
            iv_MyImageView.translatesAutoresizingMaskIntoConstraints = true
            
            let docUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let url = docUrl.appendingPathComponent(messageArr[indexPath.row].message)
            do {
                //從快取取出
                var ImageData = self.imageCache.object(forKey: url as AnyObject) as? Data
                if ImageData == nil {
                    ImageData = try Data(contentsOf: url)
                    //存入快取
                    self.imageCache.setObject(ImageData as AnyObject, forKey: url as AnyObject)
                }
                let Image = UIImage(data: ImageData!)!
                
                iv_MyImageView.frame.size.width = contentMaxWidth
                
                if rawValueDictionary["\(messageArr[indexPath.row].message)ih"] == nil {
                    if Image.size.width > contentMaxWidth {
                        rawValueDictionary["\(messageArr[indexPath.row].message)ih"] = Image.size.height / (Image.size.width / contentMaxWidth)
                    } else {
                        rawValueDictionary["\(messageArr[indexPath.row].message)ih"] = Image.size.height * (contentMaxWidth / Image.size.width)
                    }
                }
                
                iv_MyImageView.frame.size.height = rawValueDictionary["\(messageArr[indexPath.row].message)ih"]!
                
                iv_MyImageView.frame.origin.x = tableView.frame.width - contentMaxWidth - 10
                
                iv_MyImageView.image = Image
            } catch {
                print("Error loading image : \(error)")
            }
            
            return cell
        }
        
        let l_Message: PaddingLabel
        
        if messageArr[indexPath.row].isme {
            cell = tableView.dequeueReusableCell(withIdentifier: "Right", for: indexPath)
            l_Message = cell.contentView.subviews[0] as! PaddingLabel
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "Left", for: indexPath)
            l_Message = cell.contentView.subviews[2] as! PaddingLabel
        }
        
        cell.transform = CGAffineTransform(rotationAngle: -.pi)
        
        l_Message.translatesAutoresizingMaskIntoConstraints = true
        
        l_Message.text = messageArr[indexPath.row].message
        
        if rawValueDictionary["\(messageArr[indexPath.row].message)lh"] == nil {
            let rect = l_Message.text!.boundingRect(with: CGSize(width: contentMaxWidth - 40, height: 1000), options: .usesLineFragmentOrigin, attributes: [.font: l_Message.font], context: nil)
            
            rawValueDictionary["\(messageArr[indexPath.row].message)lh"] = rect.height + 40
            rawValueDictionary["\(messageArr[indexPath.row].message)lw"] = rect.width + 42
            
            if messageArr[indexPath.row].isme {
                rawValueDictionary["\(messageArr[indexPath.row].message)lx"] = tableView.frame.width - rect.width - 52
            } else {
                rawValueDictionary["\(messageArr[indexPath.row].message)lx"] = cell.contentView.subviews[0].frame.width + 20
            }
        }
        
        l_Message.frame.size.height = rawValueDictionary["\(messageArr[indexPath.row].message)lh"]!
        
        l_Message.frame.size.width = rawValueDictionary["\(messageArr[indexPath.row].message)lw"]!
        
        l_Message.frame.origin.x = rawValueDictionary["\(messageArr[indexPath.row].message)lx"]!
        
        l_Message.layer.cornerRadius = 20
        l_Message.layer.masksToBounds = true
        
        if !isLoading && !isFinishLoad && Double(indexPath.row) > Double(messageArr.count) * 0.7 {
            isLoading = true
            readMessages()
        }
        
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
