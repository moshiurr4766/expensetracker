# Firebase Firestore Rules

Use these rules in Firebase Console or deploy with Firebase CLI.

```firebase
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    match /userInfo/{userId}/{document=**} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null
          && request.auth.uid == userId
          && request.resource.data.id == userId;
      allow update: if request.auth != null
          && request.auth.uid == userId
          && resource.data.id == userId
          && request.resource.data.id == userId;
      allow delete: if request.auth != null
          && request.auth.uid == userId
          && resource.data.id == userId;
    }
    
    match /personalExpense/{userId}/{document=**} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null
          && request.auth.uid == userId
          && request.resource.data.uid == userId;
      allow update: if request.auth != null
          && request.auth.uid == userId
          && resource.data.uid == userId
          && request.resource.data.uid == userId;
      allow delete: if request.auth != null
          && request.auth.uid == userId
          && resource.data.uid == userId;
    }

    match /sharedExpense/{userId}/{document=**} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null
          && request.auth.uid == userId
          && request.resource.data.uid == userId;
      allow update: if request.auth != null
          && request.auth.uid == userId
          && resource.data.uid == userId
          && request.resource.data.uid == userId;
      allow delete: if request.auth != null
          && request.auth.uid == userId
          && resource.data.uid == userId;
    }
  }
}
```

## Notes

- This matches your app's CRUD structure under `users/{uid}`.
- After updating rules in Firebase, publish them.
- This should resolve the `permission-denied` error if the app is writing under the signed-in user's UID.
