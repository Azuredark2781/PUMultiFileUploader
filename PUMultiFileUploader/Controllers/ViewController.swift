//
//  ViewController.swift
//  PUMultiFileUploader

import UIKit
import Foundation
import Alamofire
extension UIViewController
{
    func presentAlertController(with message: String) {
      let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
      present(alert, animated: true)
    }
}
class ViewController: UIViewController {
    @IBOutlet weak var tblDoc: UITableView!
    var arrUploadContents = [FileUploadManager]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblDoc.register(UINib(nibName: "UploadingDocCell", bundle: nil), forCellReuseIdentifier: "UploadingDocCell")
    }
    
    @IBAction func didTapBrowse(_ sender: Any) {
        let vc = FilePickerVC(nibName: "FilePickerVC", bundle: nil)
        vc.modalPresentationStyle = .overCurrentContext
        vc.didselectFileArr = {(selectedFiles) in
            self.arrUploadContents = selectedFiles
            self.tblDoc.reloadData()
        }
        self.present(vc, animated: false, completion: nil)
    }
}
extension ViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return self.arrUploadContents.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UploadingDocCell", for: indexPath) as? UploadingDocCell else { return UITableViewCell() }
             if self.arrUploadContents.count > 0 {
                let uploadContent = self.arrUploadContents[indexPath.row]
                 cell.imgSelected.image = UIImage.init(data: uploadContent.imgData ?? Data())
                 cell.lblDocname.text = uploadContent.imgname ?? ""
                 
                 cell.uploadProgress.isHidden = false
                uploadContent.progressBlock = { (pro) in
                    cell.uploadProgress.progress = Float(pro ?? 0.0)
                    let progressval = (Float(pro ?? 0.0) )/100
                    cell.lblStatus.text = uploadContent.uploadStatus == .uploading ? "Uploading \(progressval)" : ""
              }
              uploadContent.uploadFile { (getUploadRepo, response, error, status) in
                  do {
                      let jsonDecoder = JSONDecoder()
                      let uploadModel = try jsonDecoder.decode(UploadFileModel.self, from:  getUploadRepo)
                      
                      if uploadModel.code == 1 {
                          cell.uploadProgress.isHidden = true
                          cell.lblStatus.text = "Upload Success...."
                      } else {
                          cell.uploadProgress.isHidden = false
                          cell.lblStatus.text = "Upload Failed...."
                      }
                  } catch {
                      cell.uploadProgress.isHidden = false
                      cell.lblStatus.text = "Upload Failed...."
                  }
              }
        }
       return cell
    }
}
