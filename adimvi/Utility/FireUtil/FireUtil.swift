//
//  FireUtil.swift
//  adimvi
//
//  Created by Aira on 12.10.2021.
//  Copyright © 2021 webdesky.com. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FireUtil {
    
    static let firebaseRef = FireUtil()
    
    //MARK: - Live Pricate Chat
    
    let privateMessageDBRef: DatabaseReference = Database.database().reference().child("PrivateMessage")
    
    func addPrivateMessage(userID1: String, userID2: String) {
        let channelID: String = getPrivateMessageChannelByCombinationUserIDS(userID1: userID1, userID2: userID2)
        let key = privateMessageDBRef.child(channelID).childByAutoId().key
        privateMessageDBRef.child(channelID).child("privateMessageID").setValue(key)
    }
    
    func receivePrivateMessage(userID1: String, userID2: String, completion: @escaping (() -> Void)) {
        let channelID: String = getPrivateMessageChannelByCombinationUserIDS(userID1: userID1, userID2: userID2)
        privateMessageDBRef.child(channelID).child("privateMessageID").observe(.value) { (snap) in
            completion()
        } withCancel: { (error) in
            print(error.localizedDescription)
        }
    }
    
    func setTypeingIndicator(userID1: String, userID2: String) {
        let channelID: String = getPrivateMessageChannelByCombinationUserIDS(userID1: userID1, userID2: userID2)
        privateMessageDBRef.child(channelID).child("typingIndicator").child(userID1).setValue(true)
    }
    
    func observePrivateMessageTypingIndicator(userID1: String, userID2: String, completion: @escaping((Bool) -> Void)) {
        let channelID: String = getPrivateMessageChannelByCombinationUserIDS(userID1: userID1, userID2: userID2)
        privateMessageDBRef.child(channelID).child("typingIndicator").child(userID2).observe(.value) { (snap) in
            if snap.exists() {
                completion(snap.value as! Bool)
            } else {
                completion(false)
            }
        }
    }
    
    func removePrivateMessageTypingIndicator(userID1: String, userID2: String) {
        let channelID: String = getPrivateMessageChannelByCombinationUserIDS(userID1: userID1, userID2: userID2)
        privateMessageDBRef.child(channelID).child("typingIndicator").child(userID1).removeValue()
    }
    
    func setChanelUserOnline(userID1: String, userID2: String) {
        let channelID: String = getPrivateMessageChannelByCombinationUserIDS(userID1: userID1, userID2: userID2)
        privateMessageDBRef.child(channelID).child("isChanelOn").child(userID1).setValue(true)
    }
    
    func observeChanelUserOnineStatus(userID1: String, userID2: String, completion: @escaping((Bool) -> Void)) {
        let channelID: String = getPrivateMessageChannelByCombinationUserIDS(userID1: userID1, userID2: userID2)
        privateMessageDBRef.child(channelID).child("isChanelOn").child(userID2).observe(.value) { (snap) in
            if snap.exists() {
                completion(snap.value as! Bool)
            } else {
                completion(false)
            }
        }
    }
    
    func removeChanelUserOnline(userID1: String, userID2: String) {
        let channelID: String = getPrivateMessageChannelByCombinationUserIDS(userID1: userID1, userID2: userID2)
        privateMessageDBRef.child(channelID).child("isChanelOn").child(userID1).removeValue()
    }
    
    func getPrivateMessageChannelByCombinationUserIDS(userID1: String, userID2: String) -> String {
        if Int(userID1)! > Int(userID2)! {
            return "\(userID1)_\(userID2)"
        } else {
            return "\(userID2)_\(userID1)"
        }
    }
    
    //MARK: - Live Chat RoomList Part
    let fireDBRoomIDS: DatabaseReference = Database.database().reference().child("RoomIDS")
    
    func createRoom(room: RoomModel, completion: @escaping(() -> Void)) {
        let key = fireDBRoomIDS.child("\(room.roomID)").childByAutoId().key
        fireDBRoomIDS.child("\(room.roomID)").child("pushKey").setValue(key) { (error, _ ) in
            if error == nil {
                completion()
            }
        }
    }
    
    func closeRoom(room: RoomModel) {
        fireDBRoomIDS.child("\(room.roomID)").removeValue()
        fireDBRoomMessage.child("\(room.roomID)").removeValue()
    }
    
    func joinLeaveRoom(room: RoomModel, isJoin: Bool) {
        var memberCnt: Int = room.memberCnt
        if isJoin {
            memberCnt += 1
        } else {
            memberCnt -= 1
        }
        fireDBRoomIDS.child("\(room.roomID)").child("members").setValue(memberCnt)
        setRoomMessage(room: room)
    }
    
    //MARK: - Room Messagge Part
    let fireDBRoomMessage: DatabaseReference = Database.database().reference().child("RoomMessages")
    
    func setRoomMessage(room: RoomModel) {
        let key = fireDBRoomMessage.child("\(room.roomID)").childByAutoId().key
        fireDBRoomMessage.child("\(room.roomID)").child("roomMessages").setValue(key)
    }
    
    func setAdminTyping(room: RoomModel) {
        fireDBRoomMessage.child("\(room.roomID)").child("isTyping").setValue(true)
    }
    
    func removeAdminTyping(room: RoomModel) {
        fireDBRoomMessage.child("\(room.roomID)").child("isTyping").removeValue()
    }
}
