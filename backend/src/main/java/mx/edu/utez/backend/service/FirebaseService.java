package mx.edu.utez.backend.service;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;
import java.io.FileInputStream;
import java.io.IOException;

@Service
public class FirebaseService {

    @PostConstruct
    public void initialize() {
        try {
            // Check if Firebase is already initialized
            if (FirebaseApp.getApps().isEmpty()) {
                // Try to load Firebase credentials from resources
                java.io.InputStream serviceAccount = getClass().getClassLoader()
                        .getResourceAsStream("firebase-service-account.json");

                if (serviceAccount != null) {
                    FirebaseOptions options = FirebaseOptions.builder()
                            .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                            .build();

                    FirebaseApp.initializeApp(options);
                    System.out.println("Firebase initialized successfully");
                } else {
                    System.out.println(
                            "Firebase credentials file not found in classpath. Push notifications will not work.");
                    System.out.println("Please ensure firebase-service-account.json is in src/main/resources/");
                }
            }
        } catch (IOException e) {
            System.err.println("Error initializing Firebase: " + e.getMessage());
        }
    }

    public void sendPushNotification(String fcmToken, String title, String body) {
        if (fcmToken == null || fcmToken.isEmpty()) {
            return; // User doesn't have a token registered
        }

        try {
            if (FirebaseApp.getApps().isEmpty()) {
                System.out.println("Firebase not initialized. Cannot send push notification.");
                return;
            }

            Notification notification = Notification.builder()
                    .setTitle(title)
                    .setBody(body)
                    .build();

            Message message = Message.builder()
                    .setToken(fcmToken)
                    .setNotification(notification)
                    .build();

            String response = FirebaseMessaging.getInstance().send(message);
            System.out.println("Successfully sent push notification: " + response);
        } catch (Exception e) {
            System.err.println("Error sending push notification: " + e.getMessage());
        }
    }

    public void sendPushNotificationToUser(mx.edu.utez.backend.model.User user, String title, String body) {
        if (user != null && user.getFcmToken() != null) {
            sendPushNotification(user.getFcmToken(), title, body);
        }
    }
}
