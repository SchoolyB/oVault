# oVault

An open source account and password manager

## Tech Stack
- SvelteKit
- TypeScript
- TailwindCSS
- OstrichDB *Written in Odin*

## Getting Started

### Prerequisites

Before trying to run oVault, ensure you have:
- [Odin compiler](https://odin-lang.org/) installed (For the backend)
- Node.js
- npm or yarn
- Python3

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/SchoolyB/oVault.git
   cd oVault
   ```

2. **Set up the backend**
   ```bash
   cd OstrichDB/bin
   ```
   Create a `.env` file in the `OstrichDB/bin` directory
   ``` bash
   touch .env
   ```
   Add the following to your new `OstrichDB/bin/.env` file (Do NOT change anything...Even the master secret)
   ```
    OSTRICH_ENV=development
    OSTRICH_SERVER_PORT=8042
    OSTRICH_MASTER_SECRET=your-very-strong-server-secret-here-minimum-32-chars
    ```

3. **Build and run the backend**
   ```bash
   cd ..
   ./scripts/local_build.sh
   ```
   The backend will start on `http://localhost:8042`

4. **From the projects root directory generate a JWT token**
   ```bash
   python3 generate_jwt.py
   ```
   Copy the token value that is output

5. **Set up the client in second terminal**
   ```bash
   cd client
   npm install
   # or
   yarn
   ```

6. **Create .env file in the root of the `client` directory**
   ```bash
   # In the client directory, create a .env file with:
   PUBLIC_OSTRICHDB_TOKEN=your_token_from_step_4
   ```

7. **Run the client**
   ```bash
   npm run dev
   # or
   yarn dev
   ```
   The client will be available at `http://localhost:5173`

## Documentation
If you are interested in learning more about my from-scratch database, OstrichDB and its slowly growing ecosystem you can find that all here :

[OstrichDB.com](https://OstrichDB.com)
[Open-OstrichDB: The from-scrath open source backend](https://github.com/Archetype-Dynamics/Open-OstrichDB)
[OstrichDB Docs](https://ostrichdb-docs.vercel.app/)
[OstrichDB-JS SDK](https://github.com/Archetype-Dynamics/ostrichdb-js)
[OstrichDB-CLI](https://github.com/Archetype-Dynamics/OstrichDB-CLI)


Contribution is more than welcome on any of theres projects including oVault!