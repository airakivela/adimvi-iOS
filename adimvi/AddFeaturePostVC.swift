//
//  AddFeaturePostVC.swift
//  adimvi
//
//  Created by Aira on 1.12.2021.
//  Copyright © 2021 webdesky.com. All rights reserved.
//

import UIKit
import StoreKit
import Alamofire

class AddFeaturePostVC: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {

    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var collectionUV: UICollectionView!
    
    var productid = ["PD1D099", "PD2D199", "PD3D499", "PD7D699", "PD14D1399"]
    var productPrices: [Float] = [0.99, 1.99, 4.99, 6.99, 13.99]
    var products: [SKProduct] = [SKProduct]()
    
    var postInfo: [String: Any] = [String: Any]()
    
    var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title =  "Destacar posts"
        collectionUV.delegate = self
        collectionUV.dataSource = self
        titleLB.text = postInfo["post_title"] as? String
        
        SKPaymentQueue.default().add(self)
        if (SKPaymentQueue.canMakePayments()) {
            let productID:Set = Set(productid)
            let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID)
            productsRequest.delegate = self
            productsRequest.start()
            
        } else {
            print("can't make purchases")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden =  false
        self.hidesBottomBarWhenPushed = false
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func didTapQuestionMark(_ sender: UIButton) {
        let alert = UIAlertController(title: "Información de posts destacados", message: "Los posts que destaques a partir de esta pantalla aparecerán en la sección de destacados de la página principal tanto de la app como de la web www.adimvi.com durante el tiempo seleccionado y el primero de la lista en este momento.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func productsRequest (_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let count : Int = response.products.count
        self.products.removeAll()
        if (count>0) {
            let validProducts = response.products
            self.products = validProducts
            self.products.sort { (p0, p1) -> Bool in
                return p0.price.floatValue < p1.price.floatValue
            }
            for product in self.products {
                print(product.priceLocale)
                print(product.price)
                print(product.localizedPrice())
            }
        } else {
            print("nothing")
        }
    }
    
    private func request(request: SKRequest!, didFailWithError error: NSError!) {
        print("Error Fetching product information");
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])    {
        print("Received Payment Transaction Response from Apple")
        for transaction:AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction{
                switch trans.transactionState {
                case .purchased:
                    print("Product Purchased");
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    CallSetFeaturePost()
                    break;
                case .failed:
                    print("Purchased Failed")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break;
                case .restored:
                    print("Already Purchased");
                    SKPaymentQueue.default().restoreCompletedTransactions()
                default:
                    break;
                }
            }
        }
    }
    
    func buyProduct(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func CallSetFeaturePost() {
        let param: [String: String] = ["id": postInfo["postid"] as! String, "duration": features[selectedIndex].timeDay]
        let myService:String = "\(WebURL.BaseUrl)\(WebURL.SET_FEATURE_POST)"
        objActivity.startActivityIndicator()
        Alamofire.request(myService, method: .post, parameters: param)
            .responseJSON { (response) in
                switch response.result {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        objActivity.stopActivity()
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FeatureDialogVC") as! FeatureDialogVC
                        self.present(vc, animated: true, completion: nil)
                    }
                    objActivity.stopActivity()
                    break
                case .failure(_):
                    objActivity.stopActivity()
                    print(response.result.error as Any)
                    break
                }
            }
    }
}

//MARK: - Collection View Delegate & DataSource
extension AddFeaturePostVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if products.isEmpty {
            return
        }
        selectedIndex = indexPath.row
        buyProduct(product: products[indexPath.row])
//        CallSetFeaturePost()
    }
}

extension AddFeaturePostVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        let width = (9.0 / 16.0) * height
        #if DEBUG
        print("w--->\(width), h--->\(height)")
        #endif
        return CGSize(width: width, height: floor(height))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 15.0, bottom: 0.0, right: 15.0)
    }
}

extension AddFeaturePostVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return features.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeatureIAPCell", for: indexPath) as! FeatureIAPCell
        cell.configCell(model: features[indexPath.row])
        return cell
    }
}

//MARK: - CollectionView Cell

class FeatureIAPCell: UICollectionViewCell {
    @IBOutlet weak var dayLB: UILabel!
    @IBOutlet weak var diaLB: UILabel!
    @IBOutlet weak var priceLB: UILabel!
    @IBOutlet weak var descLB: UILabel!
    
    func configCell(model: FeaturedIAPModel) {
        dayLB.text = model.timeDay
        diaLB.text = model.duration
        priceLB.text = model.price
        descLB.text = model.title
    }
}


//MARK: - IAP Models
class FeaturedIAPModel {
    
    var id: String = ""
    var duration: String = ""
    var price: String = ""
    var title: String = ""
    var timeDay: String = ""
    
    init(id: String = "", duration: String = "", price: String = "", title: String = "", timeDay: String = "") {
        self.id = id
        self.duration = duration
        self.price = price
        self.title = title
        self.timeDay = timeDay
    }
}

let features: [FeaturedIAPModel] = [
    FeaturedIAPModel(id: "PD1D099", duration: "Día", price: "0.99€", title: "Básico", timeDay: "1"),
    FeaturedIAPModel(id: "PD2D199", duration: "Días", price: "1.99€", title: "Estándar", timeDay: "2"),
    FeaturedIAPModel(id: "PD3D499", duration: "Días", price: "4.99€", title: "Premium", timeDay: "5"),
    FeaturedIAPModel(id: "PD7D699", duration: "Días", price: "6.99€", title: "Platino", timeDay: "7"),
    FeaturedIAPModel(id: "PD14D1399", duration: "Días", price: "13.99€", title: "Oro", timeDay: "14")
]
