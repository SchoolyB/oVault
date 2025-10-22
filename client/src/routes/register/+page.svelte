<script lang="ts">
	import { env } from '$env/dynamic/public';
	import * as lib from '$lib/utils/common';

	let username = $state('');
	let password = $state('');
	let confirmPassword = $state('');
	let error = $state('');
	let loading = $state(false);

	async function handleRegister() {
		error = '';
		loading = true;

		try {
			const token = env.PUBLIC_OSTRICHDB_TOKEN;

			// Create project "secure"
			await lib.handle_request(lib.RequestMethod.POST, lib.CREDENDIAL_PROJECT, token)

			// Create a  collection called "credentials"
			await lib.handle_request(lib.RequestMethod.POST, lib.CREDENTIAL_COLLECTION, token)

			//Create a collection called "accounts" for actual data storage
			await lib.handle_request(lib.RequestMethod.POST, lib.ACCOUNTS_COLLECTION, token)

			// Create cluster for users "creds" to store username and password
			await lib.handle_request(lib.RequestMethod.POST, lib.CREDENTIAL_CLUSTER, token)

			//Store users username and password
			await lib.store_registration_creds("username", encodeURIComponent(username), token)
			await lib.store_registration_creds("password", encodeURIComponent(password), token)

			// Registration successful redirect to login page
			window.location.href = '/login';

		} catch (err) {
			error = 'Registration failed. Please try again.';
			console.error('Registration error:', err);
		} finally {
			loading = false;
		}
	}
</script>

<div class="min-h-screen bg-slate-900">
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
					<h1 class="text-3xl font-bold text-white mb-2">Create Account</h1>
					<p class="text-slate-400">Sign up for oVault</p>
				</div>

				<!-- Registration Form -->
				<form onsubmit={(e) => { e.preventDefault(); handleRegister(); }}>
					<div class="space-y-4">
						<div>
							<label for="username" class="block text-sm font-medium text-slate-300 mb-2">
								Username
							</label>
							<input
								id="username"
								type="text"
								bind:value={username}
								class="w-full px-4 py-3 bg-slate-900/50 border border-slate-600 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent outline-none text-white placeholder-slate-500 transition"
								placeholder="Choose a username"
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
								bind:value={password}
								class="w-full px-4 py-3 bg-slate-900/50 border border-slate-600 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent outline-none text-white placeholder-slate-500 transition"
								placeholder="Create a strong password"
								autocomplete="new-password"
							/>
						</div>

						<div>
							<label for="confirm-password" class="block text-sm font-medium text-slate-300 mb-2">
								Confirm Password
							</label>
							<input
								id="confirm-password"
								type="password"
								bind:value={confirmPassword}
								class="w-full px-4 py-3 bg-slate-900/50 border border-slate-600 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent outline-none text-white placeholder-slate-500 transition"
								placeholder="Confirm your password"
								autocomplete="new-password"
							/>
						</div>

						{#if error}
							<div class="p-3 bg-red-500/10 border border-red-500/50 rounded-lg">
								<p class="text-sm text-red-400">{error}</p>
							</div>
						{/if}

						<button
							type="submit"
							disabled={loading}
							class="w-full py-3 bg-purple-600 hover:bg-purple-700 text-white font-medium rounded-lg transition duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
						>
							{loading ? 'Creating Account...' : 'Create Account'}
						</button>

						<div class="text-center mt-4">
							<p class="text-slate-400 text-sm">
								Already have an account?
								<a href="/login" class="text-purple-400 hover:text-purple-300 font-medium transition">
									Sign in
								</a>
							</p>
						</div>
					</div>
				</form>
			</div>
		</div>
	</div>
</div>
