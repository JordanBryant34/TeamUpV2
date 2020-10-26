//
//  UserController.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/20/20.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class UserController {
    
    static private let ref = Database.database().reference()
    static private let storageRef = Storage.storage().reference()
    
    static func loginUser(email: String, password: String, completion: @escaping (Result<Bool, AuthError>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (_, error) in
            if let error = error {
                let errorCode = (error as NSError).code
                
                if errorCode == 17008 {
                    Helpers.showNotificationBanner(title: "Invalid email address", subtitle: "Please check that the email address is correct and try again.", image: nil, style: .danger, textAlignment: .left)
                    completion(.failure(.thrownError(error)))
                    return
                } else if errorCode == 17011 {
                    Helpers.showNotificationBanner(title: "No user with that email exists", subtitle: "This email address is currently not in use by Team Up.", image: nil, style: .danger, textAlignment: .left)
                    completion(.failure(.thrownError(error)))
                    return
                } else if errorCode == 17009 {
                    Helpers.showNotificationBanner(title: "Incorrect password", subtitle: "Please double check the password and try again.", image: nil, style: .danger, textAlignment: .left)
                    completion(.failure(.thrownError(error)))
                    return
                }
            } else {
                Helpers.showNotificationBanner(title: "Welcome back", subtitle: "", image: nil, style: .success, textAlignment: .center)
                completion(.success(true))
                return
            }
        }
    }
    
    static func createNewUser(email: String, password: String, passwordConfirmation: String, completion: @escaping (Result<Bool, AuthError>) -> Void) {
        
        if (password.count < 8) || (password.count > 30) {
            Helpers.showNotificationBanner(title: "Invalid password length", subtitle: "Passwords have to be 8 to 30 characters long.", image: nil, style: .danger, textAlignment: .left)
            completion(.failure(.invalidPasswordLength))
            return
        }
        
        if password != passwordConfirmation {
            completion(.failure(.passwordsDontMatch))
            Helpers.showNotificationBanner(title: "Passwords don't match.", subtitle: "", image: nil, style: .danger, textAlignment: .center)
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                let errorCode = (error as NSError).code
                
                if errorCode == 17008 {
                    Helpers.showNotificationBanner(title: "Invalid email address", subtitle: "Please check that the email address is correct and try again.", image: nil, style: .danger, textAlignment: .left)
                    completion(.failure(.thrownError(error)))
                    return
                } else if errorCode == 17007 {
                    Helpers.showNotificationBanner(title: "Email already in use", subtitle: "Sign in with the email address or use a new email.", image: nil, style: .danger, textAlignment: .left)
                    completion(.failure(.thrownError(error)))
                    return
                }
                
                Helpers.showNotificationBanner(title: "Could not create account", subtitle: "An error has occurred. Please try again later.", image: nil, style: .danger, textAlignment: .left)
                completion(.failure(.thrownError(error)))
                return
            }
            
            if Auth.auth().currentUser != nil {
                completion(.success(true))
            }
        }
    }
    
    static func setupProfile(username: String, mic: MicStatus, region: String, image: UIImage?, completion: @escaping (_ success: Bool) -> Void) {
        
        if username.range(of: "[^a-zA-Z0-9]", options: .regularExpression) != nil {
            Helpers.showNotificationBanner(title: "Invalid username", subtitle: "Usernames can only contain alphanumeric characters.", image: nil, style: .danger, textAlignment: .left)
            completion(false)
            return
        } else if username.count < 6 || username.count > 15 {
            Helpers.showNotificationBanner(title: "Invalid username", subtitle: "Usernames have to be between 6 and 15 characters.", image: nil, style: .danger, textAlignment: .left)
            completion(false)
            return
        }
        
        ref.child("users").child(username).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                Helpers.showNotificationBanner(title: "Username is already in use", subtitle: "Choose a different username to continue.", image: nil, style: .danger, textAlignment: .left)
                completion(false)
            } else {
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = username

                changeRequest?.commitChanges { (error) in
                    if let error = error {
                        Helpers.showNotificationBanner(title: "An error has occured", subtitle: "Something went wrong when setting your username. Please try again later.", image: nil, style: .danger, textAlignment: .left)
                        print(error.localizedDescription)
                        completion(false)
                        return
                    }
                    
                    let values: [String : Any] = [
                        "dateJoined" : Int(NSDate().timeIntervalSince1970),
                        "lastSeen" : Int(NSDate().timeIntervalSince1970),
                        "username" : username,
                        "biography" : "No biography",
                        "profilePicUrl" : "https://www.example.com/exampleImage.jpg",
                        "region" : region,
                        "mic" : mic.rawValue
                    ]
                    
                    ref.child("users").child(username).updateChildValues(values)
                    
                    updateProfilePic(image: image)

                    completion(true)
                }
            }
        }
        
    }
    
    static func updateProfilePic(image: UIImage?) {
        guard var imageToStore = image else { return }
        
        if imageToStore.size.width > 500 && imageToStore.size.height > 500 {
            imageToStore = imageToStore.resize(newSize: CGSize(width: 500, height: 500))
        }
        
        guard let data = imageToStore.jpegData(compressionQuality: 1.0) else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let username = Auth.auth().currentUser?.displayName else { return }
        
        let imageRef = storageRef.child("profile-pictures/\(uid).jpg")
        
        imageRef.putData(data, metadata: nil) { (_, error) in
            if let error = error {
                Helpers.showNotificationBanner(title: "Something went wrong", subtitle: "We could not save your profile picture. Please try again later.", image: nil, style: .danger, textAlignment: .left)
                print(error.localizedDescription)
                return
            }
            
            imageRef.downloadURL { (url, error) in
                if let error = error {
                    Helpers.showNotificationBanner(title: "Something went wrong", subtitle: "An error occured while change your profile picture. Please try again later.", image: nil, style: .danger, textAlignment: .left)
                    print(error.localizedDescription)
                    return
                }
                
                guard let url = url else { return }
                ref.child("users").child(username).updateChildValues(["profilePicUrl" : url.absoluteString])
            }
        }
    }
    
    static func updateBio(bio: String) {
        guard let username = Auth.auth().currentUser?.displayName else { return }
    
        ref.child("users").child(username).updateChildValues(["biography" : bio])
    }
    
    static func fetchUsersGames(username: String, completion: @escaping (_ games: [Game]) -> Void) {
        ref.child("users").child(username).child("games").observeSingleEvent(of: .value) { (snapshot) in
            var games: [Game] = []
            guard let dictionary = snapshot.value as? [String : Any] else {
                completion(games)
                return
            }
            
            for key in dictionary.keys {
                if let gameDictionary = dictionary[key] as? [String : Any], let game = Game(dictionary: gameDictionary) {
                    games.append(game)
                }
            }
            
            completion(games)
        }
    }
    
    static func fetchUser(username: String, completion: @escaping (_ user: User?) -> Void) {
        ref.child("users").child(username).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String : Any] else {
                completion(nil)
                return
            }
            
            let user = User(dictionary: dictionary)
            
            completion(user)
        }
    }
    
    static func updateUserGames(games: [Game]) {
        guard let username = Auth.auth().currentUser?.displayName else { return }
        var gamesDictionary: [String : [String : Any]] = [:]
        
        for game in games {
            var platformsDictionary: [String : Int] = [:]
            
            for platform in game.platforms {
                platformsDictionary[platform] = 1
            }
            
            gamesDictionary[game.name] = [
                "backgroundImageUrl" : game.backgroundImageUrl,
                "logoImageUrl" : game.logoImageUrl,
                "name" : game.name,
                "platforms" : platformsDictionary
            ]
            
            if let playerPlatform = game.playerPlatform {
                gamesDictionary[game.name]?["playerPlatform"] = playerPlatform
            }
        }
        
        ref.child("users").child(username).updateChildValues(["games" : gamesDictionary])
    
        updateUserLFG(games: games)
    }
    
    static private func updateUserLFG(games: [Game]) {
        guard let username = Auth.auth().currentUser?.displayName else { return }
        fetchUser(username: username) { (user) in
            guard let user = user else { return }
            
            for game in GameController.shared.games {
                var lfgDictionary: [String : Any]?
                
                if let index = games.firstIndex(of: game), let platform = games[index].playerPlatform {
                    lfgDictionary = [
                        "username" : username,
                        "region" : user.region.rawValue,
                        "profilePicUrl" : user.profilePicUrl,
                        "mic" : user.mic.rawValue,
                        "platform" : platform,
                        "compoundQuery" : "\(platform)_\(user.region.rawValue)"
                    ]
                }
                
                let gameRef = ref.child("lfg").child(game.name)
                gameRef.queryOrdered(byChild: "username").queryEqual(toValue: username).observeSingleEvent(of: .value) { (snapshot) in
                    if let dictionary = snapshot.value as? NSDictionary, let autoId = dictionary.allKeys.first as? String {
                        if let lfgDictionary = lfgDictionary, games.contains(game) {
                            gameRef.child(autoId).updateChildValues(lfgDictionary)
                        } else {
                            gameRef.child(autoId).removeValue()
                        }
                    } else {
                        print("User is not already in this LFG")
                        if let lfgDictionary = lfgDictionary, games.contains(game) {
                            gameRef.childByAutoId().updateChildValues(lfgDictionary)
                        }
                    }
                }
            }
        }
    }

}
