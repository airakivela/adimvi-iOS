//
//  GuideModel.swift
//  adimvi
//
//  Created by Aira on 29.11.2021.
//  Copyright © 2021 webdesky.com. All rights reserved.
//

import Foundation
import UIKit

let APPGUIDES: [GuideModel] = [
    GuideModel(imgRes: UIImage(named: "guide_0")!, title: "¡Bienvenid@ a Adimvi!", content: "¿Tu primera vez por aquí? Esta guía rápida te ayudará a descubrir algunos aspectos importantes de la plataforma.", subContent: ""),
    GuideModel(imgRes: UIImage(named: "guide_1")!, title: "La comunidad", content: "Adimvi cuenta con una comunidad increíble de lectores y escritores con los que podrás compartir todo tipo de ideas y opiniones mediante posts, chats en vivo, muros o mensajes entre otros.", subContent: ""),
    GuideModel(imgRes: UIImage(named: "guide_2")!, title: "Todo lo que publiques está monetizado", content: "Todos tus posts te generarán ingresos desde el primer momento. Sin registros externos, sin más configuraciones ni complicaciones", subContent: "Fácil y rápido."),
    GuideModel(imgRes: UIImage(named: "guide_3")!, title: "Los créditos", content: "En Adimvi los escritores tienen la opción de compartir sus posts de manera gratuita o de pago. Los créditos te ayudarán a desbloquear estos posts de pago para acceder a su contenido.", subContent: "Puedes añadir créditos fácilmente desde tu perfil."),
    GuideModel(imgRes: UIImage(named: "guide_4")!, title: "¡Ya estaría!", content: "Con esto estás list@ para sumergirte y descubrir lo mejor del blogging con Adimvi.", subContent: "Gracias por formar parte de esta gran comunidad.")
]

class GuideModel {
        
    var imgRes: UIImage
    var title: String
    var content: String
    var subContent: String
    
    init(imgRes: UIImage, title: String, content: String, subContent: String) {
        self.imgRes = imgRes
        self.title = title
        self.content = content
        self.subContent = subContent
    }
}
