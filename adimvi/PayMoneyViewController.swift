//
//  PayMoneyViewController.swift
//  adimvi
//
//  Created by javed carear  on 17/11/1942 Saka.
//  Copyright © 1942 webdesky.com. All rights reserved.

    import UIKit
    import StoreKit
    class PayMoneyViewController:UIViewController,SKProductsRequestDelegate, SKPaymentTransactionObserver {
        var productid:NSString!
        override func viewDidLoad() {
            super.viewDidLoad()
            productid = "BDC548"
            SKPaymentQueue.default().add(self)
    
        }
        
        @IBAction func unlockAction(sender: AnyObject) {
           print("About to fetch the products")
           if (SKPaymentQueue.canMakePayments()) {
               let productID:NSSet = NSSet(object: self.productid!)
            let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
                productsRequest.delegate = self
                productsRequest.start();
              
            } else {
                print("can't make purchases")
            }
        }
        
        func productsRequest (_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
          
            let count : Int = response.products.count
            if (count>0) {
                let validProducts = response.products
                let validProduct: SKProduct = response.products[0] as SKProduct
                if (validProduct.productIdentifier == "BDC548") {
                    print(validProduct.localizedTitle)
                    print(validProduct.localizedDescription)
                    print(validProduct.price)
                    buyProduct(product: validProduct)
                } else {
                    print(validProduct.productIdentifier)
                }
            } else {
                print("nothing")
            }
        }

        private func request(request: SKRequest!, didFailWithError error: NSError!) {
            print("Error Fetching product information");
        }

        private func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!)    {
            print("Received Payment Transaction Response from Apple")

            for transaction:AnyObject in transactions {
                if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction{
                    switch trans.transactionState {
                    case .purchased:
                        print("Product Purchased");
                        SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                       
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
       
        func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
            
        }
        

    }
