# 📝 EthicFin TaskManager – Testing & Evaluation Notes

Welcome to **EthicFin TaskManager**! Below are the instructions and test credentials to help you test and evaluate all features of the application.

---

## 📞 Tester Support & Contact
If you encounter any difficulties, need assistance, or have questions while testing:
- **Phone / WhatsApp**: **+91 9061624061**

---

## 🔑 Ways to Log In & Test

### Option 1: Continue as Guest (1-Tap Instant Entry)
- Tap the **"Continue as Guest"** button on the login screen.
- Instantly enters the app without entering any credentials.
- Works 100% offline or online.

---

### Option 2: Pre-configured Test Account
Use the following test credentials on the **Sign In** screen:
- **Email**: `test@gmail.com`
- **Password**: `test@123`

---

### Option 3: Register a New Account
- Tap **"Sign Up"** at the bottom of the login screen.
- Enter any name, dummy email (e.g., `tester1@example.com`), and password (min 6 characters).
- Creates an isolated user session where all tasks added are uniquely tied to that account.

---

## 🧪 Key Features to Test

1. **Task CRUD Operations**:
   - **Create**: Tap the `+` button in the bottom right, enter title, description, select priority, choose due date & time, and save.
   - **Real-Time Validation**: Try entering short text (<3 chars for title, <5 chars for description) to see dynamic validation.
   - **Update / Toggle**: Tap any task to view details (with full copyable Task UUID), edit fields, or tap the checkmark icon to toggle completion.
   - **Delete**: Swipe or delete a task from the details/list view.

2. **Search, Filter & Sort**:
   - Search tasks by title or description in real time.
   - Filter by status (*All, Pending, Completed*) and priority (*Low, Medium, High, Urgent*).
   - Sort by due date, priority, or creation date.

3. **Offline Mode & Conflict Resolution**:
   - Turn on Airplane mode / disconnect internet.
   - Create or edit tasks locally (notice the **"Offline / Queued"** status badge in the App Bar).
   - Turn internet back on (observe automatic background sync and status switching to **"Synced"**).

4. **Theme Switcher**:
   - Tap the Sun/Moon icon in the App Bar on any screen to switch between WhatsApp-style Dark Mode and Light Mode.

5. **Push & Local Notifications**:
   - Create a new task to receive an instant local task confirmation notification.
   - Or tap the **User Avatar** (top right) > select **"Test Notification"** to trigger a test alert.

---

## 📦 Run Commands

```bash
# Run on connected device / emulator
flutter run

# Run full automated test suite
flutter test

# Run code analysis
flutter analyze
```
