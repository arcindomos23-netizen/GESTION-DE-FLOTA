// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyC6ZApOI4Q2llDSkblPYnK5wcQ_hxuOkX8",
  authDomain: "app-gestion-de-flota.firebaseapp.com",
  projectId: "app-gestion-de-flota",
  storageBucket: "app-gestion-de-flota.firebasestorage.app",
  messagingSenderId: "801593641234",
  appId: "1:801593641234:web:36812ab0499b1bc549cbcb",
  measurementId: "G-BG9TXV3XXM"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);