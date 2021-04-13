//
//  AuthError.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/23/20.
//

import Foundation

enum AuthError: Error {
    
    case incorrectUsernameOrPassword
    case passwordsDontMatch
    case invalidPasswordLength
    case thrownError(Error)
    
    var errorDescription: String? {
        switch self {
        case .incorrectUsernameOrPassword:
            return "Username or password is incorrect."
        case .passwordsDontMatch:
            return "The passwords do not match."
        case .invalidPasswordLength:
            return "The password is not long enough"
        case .thrownError(let error):
            return error.localizedDescription
        }
    }
    
}
