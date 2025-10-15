<script lang="ts">
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import PasswordCard from '$lib/components/PasswordCard.svelte';
	import PasswordModal from '$lib/components/PasswordModal.svelte';

	interface PasswordEntry {
		id: string;
		title: string;
		username: string;
		password: string;
		url?: string;
		notes?: string;
		createdAt: Date;
		updatedAt: Date;
	}

	// Vault state
	let passwords: PasswordEntry[] = $state([]);
	let searchQuery = $state('');
	let showModal = $state(false);
	let editingPassword: PasswordEntry | null = $state(null);
	let showPassword: { [key: string]: boolean } = $state({});
	let isLoggedIn = $state(false);

	// Computed
	let filteredPasswords = $derived(
		passwords.filter(
			(p) =>
				p.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
				p.username.toLowerCase().includes(searchQuery.toLowerCase()) ||
				(p.url && p.url.toLowerCase().includes(searchQuery.toLowerCase()))
		)
	);

	// Check if user is logged in on mount
	onMount(() => {
		// Check if user has an active session
		const loggedIn = sessionStorage.getItem('isLoggedIn') === 'true';
		const username = sessionStorage.getItem('username');

		if (!loggedIn || !username) {
			console.log('No active session found, redirecting to login...');
			goto('/login');
		} else {
			console.log('Active session found for user:', username);
			isLoggedIn = true;
			loadPasswords();
		}
	});

	// Load passwords from server
	async function loadPasswords() {
		try {
			// TODO: Replace with actual API call
			// const response = await fetch('http://localhost:8080/api/passwords');
			// const data = await response.json();
			// passwords = data;

			// Mock data for now
			passwords = [
				{
					id: '1',
					title: 'GitHub',
					username: 'user@example.com',
					password: 'SecurePass123!',
					url: 'https://github.com',
					notes: 'Main GitHub account',
					createdAt: new Date(),
					updatedAt: new Date()
				},
				{
					id: '2',
					title: 'Gmail',
					username: 'myemail@gmail.com',
					password: 'MySecretPass456!',
					url: 'https://mail.google.com',
					notes: 'Personal email',
					createdAt: new Date(),
					updatedAt: new Date()
				}
			];
		} catch (error) {
			console.error('Failed to load passwords:', error);
		}
	}

	// Logout handler
	function handleLogout() {
		console.log('Logging out...');
		// Clear session storage
		sessionStorage.removeItem('isLoggedIn');
		sessionStorage.removeItem('username');

		// Clear local state
		isLoggedIn = false;
		passwords = [];
		searchQuery = '';

		// Redirect to login
		goto('/login');
	}

	// Add new password
	function handleAddNew() {
		editingPassword = null;
		showModal = true;
	}

	// Edit password
	function handleEdit(password: PasswordEntry) {
		editingPassword = password;
		showModal = true;
	}

	// Delete password
	async function handleDelete(id: string) {
		if (!confirm('Are you sure you want to delete this password?')) {
			return;
		}

		try {
			// TODO: Replace with actual API call
			// await fetch(`http://localhost:8080/api/passwords/${id}`, {
			// 	method: 'DELETE'
			// });

			passwords = passwords.filter((p) => p.id !== id);
		} catch (error) {
			console.error('Failed to delete password:', error);
		}
	}

	// Save password (create or update)
	async function handleSave(password: Partial<PasswordEntry>) {
		try {
			if (editingPassword) {
				// Update existing
				// TODO: Replace with actual API call
				// await fetch(`http://localhost:8080/api/passwords/${editingPassword.id}`, {
				// 	method: 'PUT',
				// 	headers: { 'Content-Type': 'application/json' },
				// 	body: JSON.stringify(password)
				// });

				passwords = passwords.map((p) =>
					p.id === editingPassword.id ? { ...p, ...password, updatedAt: new Date() } : p
				);
			} else {
				// Create new
				// TODO: Replace with actual API call
				// const response = await fetch('http://localhost:8080/api/passwords', {
				// 	method: 'POST',
				// 	headers: { 'Content-Type': 'application/json' },
				// 	body: JSON.stringify(password)
				// });
				// const newPassword = await response.json();

				const newPassword: PasswordEntry = {
					id: Date.now().toString(),
					...password,
					createdAt: new Date(),
					updatedAt: new Date()
				} as PasswordEntry;

				passwords = [...passwords, newPassword];
			}

			showModal = false;
			editingPassword = null;
		} catch (error) {
			console.error('Failed to save password:', error);
		}
	}

	// Toggle password visibility
	function togglePasswordVisibility(id: string) {
		showPassword = { ...showPassword, [id]: !showPassword[id] };
	}
</script>

<div class="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900">
	<!-- Dashboard / Vault Page -->
	<div class="min-h-screen">
		<!-- Header -->
		<header class="bg-slate-800/50 backdrop-blur-xl border-b border-slate-700 sticky top-0 z-10">
			<div class="container mx-auto px-4 py-4">
				<div class="flex items-center justify-between">
					<div class="flex items-center space-x-3">
						<div class="w-10 h-10 bg-purple-600 rounded-xl flex items-center justify-center">
							<svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
								<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
							</svg>
						</div>
						<h1 class="text-2xl font-bold text-white">oVault Dashboard</h1>
					</div>
					<button
						onclick={handleLogout}
						class="px-4 py-2 bg-slate-700 hover:bg-slate-600 text-white rounded-lg transition"
					>
						Logout
					</button>
				</div>
			</div>
		</header>

		<!-- Main Content -->
		<div class="container mx-auto px-4 py-8">
			<!-- Search and Add Button -->
			<div class="flex flex-col sm:flex-row gap-4 mb-6">
				<div class="flex-1 relative">
					<svg class="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
					</svg>
					<input
						type="text"
						bind:value={searchQuery}
						placeholder="Search passwords..."
						class="w-full pl-12 pr-4 py-3 bg-slate-800/50 border border-slate-700 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent outline-none text-white placeholder-slate-400"
					/>
				</div>
				<button
					onclick={handleAddNew}
					class="px-6 py-3 bg-purple-600 hover:bg-purple-700 text-white font-medium rounded-lg transition duration-200 shadow-lg shadow-purple-500/30 flex items-center justify-center space-x-2"
				>
					<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
					</svg>
					<span>Add New</span>
				</button>
			</div>

			<!-- Password Count -->
			<div class="mb-4">
				<p class="text-slate-400">
					{filteredPasswords.length} {filteredPasswords.length === 1 ? 'password' : 'passwords'}
					{searchQuery ? ' found' : ' stored'}
				</p>
			</div>

			<!-- Password Grid -->
			{#if filteredPasswords.length === 0}
				<div class="text-center py-16">
					<div class="inline-flex items-center justify-center w-16 h-16 bg-slate-800 rounded-2xl mb-4">
						<svg class="w-8 h-8 text-slate-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
						</svg>
					</div>
					<h3 class="text-xl font-semibold text-slate-300 mb-2">
						{searchQuery ? 'No passwords found' : 'No passwords yet'}
					</h3>
					<p class="text-slate-500">
						{searchQuery ? 'Try a different search term' : 'Click "Add New" to create your first password'}
					</p>
				</div>
			{:else}
				<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
					{#each filteredPasswords as password (password.id)}
						<PasswordCard
							{password}
							isVisible={showPassword[password.id] || false}
							onToggleVisibility={() => togglePasswordVisibility(password.id)}
							onEdit={() => handleEdit(password)}
							onDelete={() => handleDelete(password.id)}
						/>
					{/each}
				</div>
			{/if}
		</div>
	</div>

	<!-- Password Modal -->
	{#if showModal}
		<PasswordModal
			password={editingPassword}
			onSave={handleSave}
			onClose={() => { showModal = false; editingPassword = null; }}
		/>
	{/if}
</div>
