
//  WalletViewController.swift
//  adimvi
//  Created by javed carear  on 30/09/19.
//  Copyright © 2019 webdesky.com. All rights reserved.


import UIKit
import Alamofire
import StoreKit
class WalletViewController: UIViewController,SKProductsRequestDelegate, SKPaymentTransactionObserver {
    @IBOutlet weak var AcumulatedBalance: UILabel!
    @IBOutlet weak var CreditBalance: UILabel!
    @IBOutlet weak var applyUB: UIButton!
    @IBOutlet weak var preUB: UIButton!
    @IBOutlet weak var nextUB: UIButton!
    @IBOutlet weak var purchaseUB: UIButton!
    var selectedIndex: Int = 0
    var userId:String!
    var productid = ["BDC548", "BDC998", "BDC2498", "BDC4998"]
    var productPrices: [Float] = [5.49, 9.99, 24.99, 49.99]
    var products: [SKProduct] = [SKProduct]()
    var pricevalues:Float = 5.49
    var arrayWallet =  [[String: Any]]()
    var isAbleToRequest: Bool!
    override func viewDidLoad() {
        super.viewDidLoad()
        userId = UserDefaults.standard.string(forKey: "ID")
        CallWebserviceWallet()
        SKPaymentQueue.default().add(self)
        if (SKPaymentQueue.canMakePayments()) {
            let productID:Set = Set(productid)
            let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID)
            productsRequest.delegate = self
            productsRequest.start()
            
        } else {
            print("can't make purchases")
        }
        preUB.tintColor = .lightGray
        nextUB.tintColor = .white
    }
    @IBAction func OnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapNextUb(_ sender: UIButton) {
        if sender.tag == 0 {
            nextUB.tintColor = .white
            if selectedIndex == 0 {
                return
            } else {
                selectedIndex -= 1
            }
            if selectedIndex == 0 {
                preUB.tintColor = .lightGray
            } else {
                preUB.tintColor = .white
            }
        } else if sender.tag == 1 {
            preUB.tintColor = .white
            if selectedIndex == 3 {
                return
            } else {
                selectedIndex += 1
            }
            if selectedIndex == 3 {
                nextUB.tintColor = .lightGray
            } else {
                nextUB.tintColor = .white
            }
        }
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.purchaseUB.alpha = 0.0
                UIView.animate(withDuration: 0.3) {
                    self.purchaseUB.alpha = 1.0
                    self.purchaseUB.setTitle("Depositar - \(self.productPrices[self.selectedIndex]) créditos", for: .normal)
                }
            }
        }
        
    }
    
    @IBAction func didTapQuestion1(_ sender: Any) {
        let actionSheetController: UIAlertController = UIAlertController(title: "Dinero acumulado", message: "Este balance muestra todo el dinero que han generado y acumulado tus posts por la venta de los mismos o por el numero de visualizaciones que han conseguido. Una vez llegues al mínimo establecido, podrás solicitar la cantidad acumulada.", preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .cancel) { action -> Void in
        }
        actionSheetController.addAction(cancelAction)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    @IBAction func didTapQuestion2(_ sender: Any) {
        let actionSheetController: UIAlertController = UIAlertController(title: "Créditos", message: "Este balance muestra la cantidad de créditos que has introducido en la plataforma para poder desbloquear los llamados posts PREMIUM, aquellos posts que son de pago.", preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .cancel) { action -> Void in
        }
        actionSheetController.addAction(cancelAction)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    func CallWebserviceWallet(){
        let Para =
            ["userid":"\(userId!)"
            ] as [String : Any]
        
        let myService:String = "\(WebURL.BaseUrl)\(WebURL.userBalance)"
        objActivity.startActivityIndicator()
        Alamofire.request(myService, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["balance"] as? [[String:Any]]{
                            self.arrayWallet = arr
                            print(self.arrayWallet)
                            let data =  self.arrayWallet[0]
                            if let Credit = data["credit"]as? String{
                                
                                self.CreditBalance.text = Credit
                            }
                            if let Money = data["accumulated_money"]as? String{
                                self.AcumulatedBalance.text =  Money
                                if Double(Money.replacingOccurrences(of: " ", with: ""))! > 10.0 {
                                    self.applyUB.backgroundColor = UIColor(named: "Dark light grey (dark mode)")
                                    self.isAbleToRequest = true
                                } else {
                                    self.applyUB.backgroundColor = UIColor(named: "lighter_gray")
                                    self.isAbleToRequest = false
                                }
                            }
                        }
                        objActivity.stopActivity()
                        DispatchQueue.main.async {
                            
                        }
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
    
    @IBAction func unlockAction(sender: AnyObject) {
        buyProduct(product: products[selectedIndex])
    }
    
    @IBAction func onTapApplyUB(_ sender: Any) {
        if isAbleToRequest {
            let actionSheetController: UIAlertController = UIAlertController(title: "Solicitud", message: "Puedes solicitar tu dinero acumulado o transferir el dinero a tu balance de créditos entrando en www.adimvi.conm ", preferredStyle: .alert)
            let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .cancel) { action -> Void in
            }
            actionSheetController.addAction(cancelAction)
            self.present(actionSheetController, animated: true, completion: nil)
        } else {
            let actionSheetController: UIAlertController = UIAlertController(title: "Solicitud", message: "No puedes solicitar la cantidad acumulada hasta que no alcances la cantidad mínima de 10$", preferredStyle: .alert)
            let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .cancel) { action -> Void in
            }
            actionSheetController.addAction(cancelAction)
            self.present(actionSheetController, animated: true, completion: nil)
        }
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
                    
                    CallWebserviceWalletpurechace(transid: trans.transactionIdentifier! as Any,payment:productPrices[selectedIndex])
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
    
    func showAlert(title: String = "Mensaje", strMessage:String) ->() {
        let actionSheetController: UIAlertController = UIAlertController(title: title, message: strMessage, preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .cancel) { action -> Void in
        }
        actionSheetController.addAction(cancelAction)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    func CallWebserviceWalletpurechace(transid:Any,payment:Any){
        let Para =
            ["userid":"\(userId!)",
             "txnid":"\(transid)","usd":"\(payment)","status":"done"
            ] as [String : Any]
        
        let myService:String = "\(WebURL.BaseUrl)\(WebURL.savecredit)"
        objActivity.startActivityIndicator()
        Alamofire.request(myService, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        let Credit = myData["now_credit"] as! NSNumber
                        self.CreditBalance.text = "\(Credit)"
                        
                        objActivity.stopActivity()
                        DispatchQueue.main.async {
                            
                        }
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

extension SKProduct {
    func localizedPrice() -> String {
        let fomatter = NumberFormatter()
        fomatter.numberStyle = .currency
        fomatter.locale = priceLocale
        return fomatter.string(from: self.price)!
    }
}
