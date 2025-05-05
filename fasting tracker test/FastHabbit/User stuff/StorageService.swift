//
//  StorageService.swift
//  FastHabbit
//
//  Created by Amy  on 23/04/2025.
//


import FirebaseStorage
import SwiftUI

final class StorageService {
    
  static let shared = StorageService()
  private let storage = Storage.storage().reference()

  func uploadProfileImage(_ data: Data, for uid: String, completion: @escaping (Result<URL,Error>) -> Void) {
    let ref = storage.child("profileImages/\(uid).jpg")

    // optionally set the mime‐type
    let meta = StorageMetadata()
    meta.contentType = "image/jpeg"

    ref.putData(data, metadata: meta) { metadata, err in
      if let err = err {
        print("🔥 putData failed:", err)
        return completion(.failure(err))
      }
      print("✅ putData succeeded, metadata:", metadata as Any)

      ref.downloadURL { url, err in
        if let err = err {
          print("🔥 downloadURL failed:", err)
          return completion(.failure(err))
        }
        guard let url = url else {
          print("🔥 downloadURL returned nil URL")
          return completion(.failure(NSError(domain:"", code:-1, userInfo:nil)))
        }
        print("✅ downloadURL:", url)
        completion(.success(url))
      }
    }
  }
}
