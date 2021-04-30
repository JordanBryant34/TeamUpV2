//
//  UserController.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/20/20.
//

import Foundation
import Firebase

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
                } else {
                    Helpers.showNotificationBanner(title: "Something went wrong", subtitle: "Please try again later.", image: nil, style: .danger, textAlignment: .left)
                    completion(.failure(.thrownError(error)))
                    return
                }
                        
            } else {
                Helpers.showNotificationBanner(title: "Welcome back", subtitle: "", image: nil, style: .success, textAlignment: .center)
                fetchUserData()
                fetchFCMToken()
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
    
    static func setupProfile(username: String, mic: MicStatus, region: String, profileImageUrl: String, completion: @escaping (_ success: Bool) -> Void) {
        
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
                        "searchName" : username.lowercased(),
                        "biography" : "No biography",
                        "profilePicUrl" : profileImageUrl,
                        "region" : region,
                        "mic" : mic.rawValue
                    ]
                    
                    ref.child("users").child(username).updateChildValues(values)
                    
                    fetchUserData()
                    fetchFCMToken()
                    
                    completion(true)
                }
            }
        }
        
    }
    
    static func updateBio(bio: String) {
        guard let username = Auth.auth().currentUser?.displayName else { return }
    
        ref.child("users").child(username).updateChildValues(["biography" : bio])
        editUserLFGInfo()
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
                        "biography" : user.bio,
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
                        if let lfgDictionary = lfgDictionary, games.contains(game) {
                            gameRef.childByAutoId().updateChildValues(lfgDictionary)
                        }
                    }
                }
            }
        }
    }
    
    static func editUserLFGInfo() {
        guard let currentUser = Auth.auth().currentUser?.displayName else { return }
        
        fetchUsersGames(username: currentUser) { (games) in
            if !games.isEmpty {
                updateUserLFG(games: games)
            }
        }
    }
    
    static func searchUsers(searchText: String, completion: @escaping (_ users: [User]) -> Void) {
        let searchText = searchText.lowercased()
        Database.database().reference().child("users").queryOrdered(byChild: "searchName").queryStarting(atValue: searchText).queryEnding(atValue: searchText+"\u{f8ff}").observeSingleEvent(of: .value) { (snapshot) in
            var users: [User] = []
            
            guard let dictionary = snapshot.value as? [String : Any] else {
                completion(users)
                return
            }
            
            for key in dictionary.keys {
                if let userDictionary = dictionary[key] as? [String : Any], let user = User(dictionary: userDictionary) {
                    users.append(user)
                }
            }
            
            users = users.sorted(by: { $0.username < $1.username })
            completion(users)
        }
    }
    
    static func fetchUsers(usernames: [String], completion: @escaping (_ users: [User]) -> Void) {
        let dispatchGroup = DispatchGroup()
        var users: [User] = []
        
        for username in usernames {
            dispatchGroup.enter()
            fetchUser(username: username) { (user) in
                if let user = user {
                    users.append(user)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(users)
        }
    }
    
    static func editRegion(viewController: UIViewController) {
        guard let username = Auth.auth().currentUser?.displayName else { return }
        let alertController = UIAlertController(title: "Select a region", message: nil, preferredStyle: .actionSheet)
        
        for region in Region.allCases {
            let action = UIAlertAction(title: region.rawValue, style: .default) { (_) in
                ref.child("users").child(username).updateChildValues(["region" : region.rawValue])
                editUserLFGInfo()
                NotificationCenter.default.post(name: Notification.Name("profileUpdated"), object: nil)
                Helpers.showNotificationBanner(title: "Region changed to \(region.rawValue)", subtitle: "", image: nil, style: .success, textAlignment: .center)
            }
            
            alertController.addAction(action)
        }
    
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    static func editMicStatus(viewController: UIViewController) {
        guard let username = Auth.auth().currentUser?.displayName else { return }
        let alertController = UIAlertController(title: "Select a mic status", message: nil, preferredStyle: .actionSheet)
        
        let micAction = UIAlertAction(title: "Mic", style: .default) { (_) in
            ref.child("users").child(username).updateChildValues(["mic" : "mic"])
            editUserLFGInfo()
            NotificationCenter.default.post(name: Notification.Name("profileUpdated"), object: nil)
            Helpers.showNotificationBanner(title: "Mic status changed", subtitle: "", image: nil, style: .success, textAlignment: .center)
        }
        
        let noMicAction = UIAlertAction(title: "No Mic", style: .default) { (_) in
            ref.child("users").child(username).updateChildValues(["mic" : "noMic"])
            editUserLFGInfo()
            NotificationCenter.default.post(name: Notification.Name("profileUpdated"), object: nil)
            Helpers.showNotificationBanner(title: "Mic status changed", subtitle: "", image: nil, style: .success, textAlignment: .center)
        }
        
        alertController.addAction(micAction)
        alertController.addAction(noMicAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    static func fetchUserData() {
        MessageController.shared.fetchChats()
        TeammateController.shared.fetchTeammates()
        RequestController.shared.fetchTeammateRequests()
        GameController.shared.fetchCurrentlyPlayedGame()
        UserController.fetchAllProfilePictures()
        
        GameController.shared.fetchAllGames { (games) in
            for game in games {
                GameController.shared.fetchGameBackground(game: game)
                GameController.shared.fetchGameLogo(game: game)
            }
        }
    }
    
    static func signOutUser(viewController: UIViewController) {
        do {
            MessageController.shared.clearDataAndObservers()
            TeammateController.shared.clearDataAndObservers()
            RequestController.shared.clearDataAndObservers()
            removeFCMToken()
            
            try Auth.auth().signOut()
            
            let signInViewController = UINavigationController(rootViewController: SignInViewController())
            viewController.view.window?.rootViewController = signInViewController
        } catch {
            Helpers.showNotificationBanner(title: "Something went wrong", subtitle: "We were unable to log you out. Try again later or restart the app.", image: nil, style: .danger, textAlignment: .left)
        }
    }
    
    static func fetchAllProfilePictures(completion: @escaping (_ imageUrlsDictionary: [String: [String]]) -> Void = { _ in } ) {
        ref.child("profilePics").observeSingleEvent(of: .value) { (snapshot) in
            guard let urlsDictionary = snapshot.value as? [String : Any] else { completion([:]); return }
            
            var imageUrlsDictionary: [String : [String]] = [:]
            
            for category in urlsDictionary.keys {
                if let categoryDictionary = urlsDictionary[category] as? [String : String] {
                    let arrayOfImageUrls = Array(categoryDictionary.values.sorted())
                    imageUrlsDictionary[category] = arrayOfImageUrls
                    
                    for imageUrl in arrayOfImageUrls {
                        fetchProfilePicture(picUrl: imageUrl)
                    }
                }
            }
            
            completion(imageUrlsDictionary)
        }
    }
    
    static func fetchProfilePicture(picUrl: String, completion: @escaping (_ image: UIImage) -> Void = { _ in } ) {
        let imagePathForStorage = "\(picUrl.removeSpecialCharsFromString()).jpg"
        if let image = Helpers.getImageFromFile(pathComponent: imagePathForStorage) {
            completion(image)
        } else {
            if let url = URL(string: picUrl) {
                ImageService.getImage(withURL: url) { (image) in
                    guard let image = image else {completion(UIImage(named: "defaultProfilePic")!); return }
                    Helpers.storeJpgToFile(image: image, pathComponent: imagePathForStorage, size: image.size)
                    completion(image)
                }
            } else {
                completion(UIImage(named: "defaultProfilePic")!)
            }
        }
    }
    
    static func setProfilePicture(imageUrl: String) {
        guard let currentUser = Auth.auth().currentUser?.displayName else { return }
        
        ref.child("users").child(currentUser).updateChildValues(["profilePicUrl" : imageUrl])
        editUserLFGInfo()
        NotificationCenter.default.post(name: Notification.Name("profileUpdated"), object: nil)
    }
    
    static func fetchFCMToken() {
        Messaging.messaging().token { (token, error) in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                guard let currentUser = Auth.auth().currentUser?.displayName else { return }
                ref.child("users").child(currentUser).updateChildValues(["fcmToken" : token])
            }
        }
    }
    
    static func removeFCMToken() {
        guard let currentUser = Auth.auth().currentUser?.displayName else { return }
        ref.child("users").child(currentUser).updateChildValues(["fcmToken" : " "])
    }
}
