\# Technical Task – Lewensplatform Mobile Application (iOS \& Android)



\## 1. General Information



\- \*\*Project Name:\*\* Lewensplatform

&nbsp;   

\- \*\*Platforms:\*\* 

&nbsp;	- iOS (Swift, iOS 15+)

&nbsp;	- Android (Kotlin, Android 9+)

&nbsp;   

&nbsp;- \*\*Authentication:\*\* Keycloak (OAuth 2.0, OpenID Connect).

&nbsp;   

\- \*\*Languages (UI localization):\*\*

&nbsp;   

&nbsp;   - English

&nbsp;       

&nbsp;   - German

&nbsp;       

&nbsp;   - Polish

&nbsp;       

&nbsp;   - Dutch

&nbsp;       



---



\## 2. Architecture



\- \*\*Frontend:\*\* Mobile app (iOS, Android).

&nbsp;   

\- \*\*Backend:\*\* Existing APIs (see OpenAPI spec).

&nbsp;   

\- \*\*Authentication flow:\*\*

&nbsp;   

&nbsp;   - Mobile app redirects to Keycloak login page.

&nbsp;       

&nbsp;   - OAuth 2.0 Authorization Code Flow (PKCE).

&nbsp;       

&nbsp;   - Tokens (Access/Refresh) stored securely (Keychain / Secure Storage).

&nbsp;       



---



\## 3. Main Features



\### 3.1 Home Page



\- Layout: Tile-based navigation.

&nbsp;   

\- Tiles:

&nbsp;   

&nbsp;   1. \*\*Downloads\*\*

&nbsp;       

&nbsp;   2. \*\*Customers (Debitoren)\*\*

&nbsp;       



---



\### 3.2 Downloads



\- \*\*Data Source:\*\* According to local file structure exposed via API (OpenAPI spec).

&nbsp;   

\- \*\*UI:\*\*

&nbsp;   

&nbsp;   - Table/List view of \*\*folders\*\* and \*\*files\*\*.

&nbsp;       

&nbsp;   - Expand/collapse folders.

&nbsp;       

&nbsp;   - Tap on file → download to device (with progress indicator).

&nbsp;       

&nbsp;   - Support for offline storage (downloads cached).

&nbsp;       



---



\### 3.3 Customers (Debitoren)



\- \*\*Table/List view\*\* of all customers (from `/customers` endpoint).

&nbsp;   

\- \*\*Features:\*\*

&nbsp;   

&nbsp;   - Search bar (by name, customer number, etc.).

&nbsp;       

&nbsp;   - Pagination (if API provides).

&nbsp;       

\- \*\*Row click → opens Customer Card.\*\*

&nbsp;   



---



\### 3.4 Customer Card



\- \*\*Data Source:\*\* `/customers/{id}` endpoint.

&nbsp;   

\- \*\*Sections:\*\*

&nbsp;   

&nbsp;   1. \*\*General Attributes\*\* (Name, Address, Contact, etc. → see `customers.yaml`).

&nbsp;       

&nbsp;   2. \*\*Assigned Discounts Table\*\*

&nbsp;       

&nbsp;       - Data from `/discount\_assignments` (see `discount\_assignments.yaml`).

&nbsp;           

&nbsp;       - Table with columns: Discount Code, Description, Value, Validity.

&nbsp;           

&nbsp;   3. \*\*Hyperlink to open (Orders Table):\*\*

&nbsp;       

&nbsp;           

\### 3.5 Orders



\- \*\*Table/List view\*\* of all orders (from `/orders` endpoint).

&nbsp;   

\- \*\*Features:\*\*

&nbsp;   

&nbsp;   - Search bar (by No, customer number, etc.).

&nbsp;       

&nbsp;   - Pagination (if API provides).

&nbsp;       

---



\## 4. Technical Requirements



\- \*\*Authentication \& Security\*\*

&nbsp;   

&nbsp;   - OAuth 2.0 PKCE with Keycloak.

&nbsp;       

&nbsp;   - Secure token storage (Keychain iOS / EncryptedSharedPrefs Android).

&nbsp;       

\- \*\*API Integration\*\*

&nbsp;   

&nbsp;   - Use OpenAPI-generated client SDK where possible.

&nbsp;       

&nbsp;   - Endpoints:

&nbsp;       

&nbsp;       - `/customers` (list, details)

&nbsp;           

&nbsp;       - `/discount\_assignments` (list by customer)

&nbsp;           

&nbsp;       - `/downloads` (folders \& files)

&nbsp;       - '/orders' (list)

&nbsp;           

\- \*\*Caching\*\*

&nbsp;   

&nbsp;   - Customer data, downloads, discount\_assignments and orders cached locally.

&nbsp;       

&nbsp;   - Refresh mechanism on app start / pull-to-refresh.

&nbsp;       



---



\## 5. UI/UX



\- \*\*Navigation:\*\* Bottom navigation or side menu.

&nbsp;   

\- \*\*Home Tiles:\*\* Big clickable tiles with icons.

&nbsp;   

\- \*\*Languages:\*\* Switchable based on device locale (only en, de, nl, pl).

&nbsp;   

\- \*\*Responsive Layout:\*\* Tablet support.

&nbsp;   



---



\## 6. Non-Functional Requirements



\- \*\*Performance:\*\*

&nbsp;   

&nbsp;   - API calls optimized with pagination \& caching.

&nbsp;       

&nbsp;   - Lazy loading for downloads \& customers.

&nbsp;       

\- \*\*Scalability:\*\*

&nbsp;   

&nbsp;   - Modular architecture to add more tiles in the future.

&nbsp;       

\- \*\*Testing:\*\*

&nbsp;   

&nbsp;   - Unit tests, API mock tests, UI tests.

&nbsp;       

\- \*\*Compliance:\*\*

&nbsp;   

&nbsp;   - GDPR compliant data handling.

&nbsp;       

&nbsp;   - HTTPS enforced.

&nbsp;       



---



\## 7. Deliverables



\- iOS app in Swift (Xcode project) 

\- Android app in Kotlin (Maven/Gradle project) 

\- Shared GitHub repository with: 

&nbsp;	- Complete code 

&nbsp;	- OpenAPI specifications Documentation (README, Contribution Guide) 



&nbsp; 

