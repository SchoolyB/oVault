<script lang="ts">
	import { onMount } from 'svelte';
	import { env } from '$env/dynamic/public';
	import { goto } from '$app/navigation';

	let loginUsername = $state('');
	let loginPassword = $state('');
	let loginError = $state('');
	let loading = $state(false);

	// Check if user is already logged in
	onMount(() => {
		const isLoggedIn = sessionStorage.getItem('isLoggedIn') === 'true';
		if (isLoggedIn) {
			console.log('User already logged in, redirecting to dashboard...');
			goto('/dashboard');
		}
	});

	export async function show_me_key() {
		console.log(env.PUBLIC_OSTRICHDB_TOKEN);
	}

	// Define the response type from OstrichDB
	interface OstrichDBRecord {
		id: string;
		name: string;
		type: string;
		value: string;
	}

	// Login handler
	async function handleLogin() {
		loginError = '';
		loading = true;
		show_me_key();

		if (!loginUsername || !loginPassword) {
			loginError = 'Please enter both username and password';
			loading = false;
			return;
		}

		try {
			const token = env.PUBLIC_OSTRICHDB_TOKEN;
			const baseUrl = 'http://localhost:8042/api/v1';

			// Fetch stored username from database
			const usernameResponse = await fetch(
				`${baseUrl}/projects/secure/collections/credentials/clusters/creds/records/username`,
				{
					method: 'GET',
					headers: {
						Authorization: `Bearer ${token}`,
						'Content-Type': 'application/json',
						Accept: 'application/json'
					}
				}
			);

			// Fetch stored password from database
			const passwordResponse = await fetch(
				`${baseUrl}/projects/secure/collections/credentials/clusters/creds/records/password`,
				{
					method: 'GET',
					headers: {
						Authorization: `Bearer ${token}`,
						'Content-Type': 'application/json',
						Accept: 'application/json'
					}
				}
			);

			// Check if both requests were successful
			if (!usernameResponse.ok || !passwordResponse.ok) {
				console.error('Failed to fetch credentials from server');
				console.error('Username response status:', usernameResponse.status);
				console.error('Password response status:', passwordResponse.status);
				loginError = 'Failed to verify credentials. Please try again.';
				return;
			}

			// Parse JSON responses
			const usernameData: OstrichDBRecord = await usernameResponse.json();
			const passwordData: OstrichDBRecord = await passwordResponse.json();

			console.log('Fetched username record:', usernameData);
			console.log('Fetched password record:', passwordData);

			// Extract the values from the response
			const storedUsername = usernameData.value;
			const storedPassword = passwordData.value;

			// Verify that entered credentials match stored credentials
			if (loginUsername === storedUsername && loginPassword === storedPassword) {
				console.log('Login successful! Redirecting to dashboard...');

				// Store login state in sessionStorage
				sessionStorage.setItem('isLoggedIn', 'true');
				sessionStorage.setItem('username', loginUsername);

				// Login successful - redirect to user dashboard
				goto('/dashboard');
			} else {
				console.log('Credentials do not match');
				console.log('Entered username matches:', loginUsername === storedUsername);
				console.log('Entered password matches:', loginPassword === storedPassword);
				loginError = 'Invalid username or password';
			}
		} catch (error) {
			loginError = 'Failed to connect to server';
			console.error('Login error:', error);
		} finally {
			loading = false;
		}
	}
</script>

<div class="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900">
	<!-- Login Page -->
	<div class="flex items-center justify-center min-h-screen px-4">
		<div class="w-full max-w-md">
			<div class="bg-slate-800/50 backdrop-blur-xl rounded-2xl shadow-2xl p-8 border border-slate-700">
				<!-- Logo/Title -->
				<div class="text-center mb-8">
					<div class="inline-flex items-center justify-center w-16 h-16 bg-purple-600 rounded-2xl mb-4">
						<svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
						</svg>
					</div>
					<h1 class="text-3xl font-bold text-white mb-2">oVault</h1>
					<p class="text-slate-400">Your secure password manager</p>
				</div>

				<!-- Login Form -->
				<form onsubmit={(e) => { e.preventDefault(); handleLogin(); }}>
					<div class="space-y-4">
						<div>
							<label for="username" class="block text-sm font-medium text-slate-300 mb-2">
								Username
							</label>
							<input
								id="username"
								type="text"
								bind:value={loginUsername}
								class="w-full px-4 py-3 bg-slate-900/50 border border-slate-600 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent outline-none text-white placeholder-slate-500 transition"
								placeholder="Enter your username"
								autocomplete="username"
							/>
						</div>

						<div>
							<label for="password" class="block text-sm font-medium text-slate-300 mb-2">
								Password
							</label>
							<input
								id="password"
								type="password"
								bind:value={loginPassword}
								class="w-full px-4 py-3 bg-slate-900/50 border border-slate-600 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent outline-none text-white placeholder-slate-500 transition"
								placeholder="Enter your password"
								autocomplete="current-password"
							/>
						</div>

						{#if loginError}
							<div class="p-3 bg-red-500/10 border border-red-500/50 rounded-lg">
								<p class="text-sm text-red-400">{loginError}</p>
							</div>
						{/if}

						<button
							type="submit"
							disabled={loading}
							class="w-full py-3 bg-purple-600 hover:bg-purple-700 text-white font-medium rounded-lg transition duration-200 shadow-lg shadow-purple-500/50 disabled:opacity-50 disabled:cursor-not-allowed"
						>
							{loading ? 'Signing In...' : 'Sign In'}
						</button>

						<div class="text-center mt-4">
							<p class="text-slate-400 text-sm">
								Don't have an account?
								<a href="/register" class="text-purple-400 hover:text-purple-300 font-medium transition">
									Sign up
								</a>
							</p>
						</div>
					</div>
				</form>
			</div>
		</div>
	</div>
</div>
