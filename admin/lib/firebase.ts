import { initializeApp, getApps, FirebaseApp } from "firebase/app";
import { getStorage, ref, uploadBytes, getDownloadURL } from "firebase/storage";

const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY,
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN ?? "vedic-mate.firebaseapp.com",
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID ?? "vedic-mate",
  storageBucket: process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET ?? "vedic-mate.firebasestorage.app",
  messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID || "848781830717",
  appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID,
};

let app: FirebaseApp | null = null;

export function getFirebaseApp(): FirebaseApp | null {
  if (!firebaseConfig.apiKey || !firebaseConfig.projectId) return null;
  if (getApps().length === 0) {
    app = initializeApp(firebaseConfig);
  }
  return app ?? null;
}

export async function uploadReelToFirebase(file: File): Promise<string | null> {
  const firebaseApp = getFirebaseApp();
  if (!firebaseApp) return null;
  try {
    const storage = getStorage(firebaseApp);
    const filename = `reels/reel_${Date.now()}.${file.name.split(".").pop() || "mp4"}`;
    const storageRef = ref(storage, filename);
    await uploadBytes(storageRef, file);
    const url = await getDownloadURL(storageRef);
    return url;
  } catch (err) {
    console.error("Firebase upload error:", err);
    return null;
  }
}

export function isFirebaseConfigured(): boolean {
  return !!(process.env.NEXT_PUBLIC_FIREBASE_API_KEY && process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID);
}
