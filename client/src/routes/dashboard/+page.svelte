<script lang="ts">
	import { onMount } from 'svelte';
	import { env } from '$env/dynamic/public';
	import { goto } from '$app/navigation';
	import * as lib from '$lib/utils/common';
	import AccountCard from '$lib/components/AccountCard.svelte';
	import AccountModal from '$lib/components/AccountModal.svelte';
	import type { AccountEntry } from '$lib/utils/common';


	// Vault state
	let accounts: AccountEntry[] = $state([]);
	let searchQuery = $state('');
	let showModal = $state(false);
	let editingAccount: AccountEntry | null = $state(null);
	let showPassword: { [key: string]: boolean } = $state({});
	let isLoggedIn = $state(false);




	let filteredAccounts = $derived(
		accounts.filter(
			(acct) =>
			acct.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
			acct.username.toLowerCase().includes(searchQuery.toLowerCase()) ||
			(acct.email && acct.email.toLowerCase().includes(searchQuery.toLowerCase())) ||
			(acct.url && acct.url.toLowerCase().includes(searchQuery.toLowerCase()))
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
			get_accounts();
		}
	});

	// Load passwords from server
	async function get_accounts() {
		try {
			const token = env.PUBLIC_OSTRICHDB_TOKEN;
			//Firstly GET all names of Clusters in the Collection as an array
			// Then for each name in the array, send another request getting actual Record information.
			// Have to do it this way because I fucked up something when building OstrichDB's request handlers
			let response = await lib.handle_request(lib.RequestMethod.GET, lib.ALL_ACCOUNTS, token)
			const clusterData = await response.json();

			const loadedAccounts: AccountEntry[] = [];

			//Loop over each Cluster to get their names
			for (const cluster of clusterData.clusters) {
				let nextResponse = await lib.handle_request(lib.RequestMethod.GET, `${lib.ALL_ACCOUNTS}/${cluster.name}`, token)
				const recordData = await nextResponse.json()

				//For each record in recordData make an AccountEntry
				const accountEntry: AccountEntry = {
					id: cluster.id || cluster.name,
					title: '',
					username: '',
					password: '',
					url: '',
					notes: '',
					tags: [],
					createdAt: new Date(),
					updatedAt: new Date()
				};

				// Map records to AccountEntry fields
				if (recordData.records) { //This shit is dumb. Checking if the 'records' property exists...Should be a .exists() method..but no
					for (const record of recordData.records) {
						switch (record.name) {
							case 'title':
								accountEntry.title = record.value;
								break;
							case 'email':
								accountEntry.email = record.value ? decodeURIComponent(record.value) : '';
								break;
							case 'username':
								accountEntry.username = record.value ? decodeURIComponent(record.value) : '';
								break;
							case 'password':
								accountEntry.password = record.value ? decodeURIComponent(record.value) : '';
								break;
							case 'url':
								accountEntry.url = record.value ? decodeURIComponent(record.value) : '';
								break;
							case 'notes':
								accountEntry.notes = record.value ? decodeURIComponent(record.value) : '';
								break;
							case 'tags':
							    //TODO: come back to me
								try {
									accountEntry.tags = JSON.parse(record.value);
								} catch {
									accountEntry.tags = record.value ? record.value.split(',').map(t => t.trim()) : [];
								}
								break;
							case 'createdAt':
								accountEntry.createdAt = new Date(record.value);
								break;
							case 'updatedAt':
								accountEntry.updatedAt = new Date(record.value);
								break;
						}
					}
				}

				loadedAccounts.push(accountEntry);
			}

			accounts = loadedAccounts;
			console.log(`Loaded ${accounts.length} accounts from database`);
		} catch (error) {
			console.error('Failed to load accounts:', error);
		}
	}

	// Logout handler
	function handle_logout() {
		console.log('Logging out...');
		// Clear session storage
		sessionStorage.removeItem('isLoggedIn');
		sessionStorage.removeItem('username');

		// Clear local state
		isLoggedIn = false;
		accounts = [];
		searchQuery = '';


		goto('/login');
	}

	function handle_adding_new_account_entry() {
		editingAccount = null;
		showModal = true;
	}

	// Edit password
	function handle_editing_account_entry(account: AccountEntry) {
		editingAccount = account;
		showModal = true;
	}

	// Delete password
	async function handle_deleting_account_entry(id: string) {
		if (!confirm('Are you sure you want to delete this password?')) {
			return;
		}

		try {
			// TODO: Replace with actual API call
			// await fetch(`http://localhost:8080/api/passwords/${id}`, {
			// 	method: 'DELETE'
			// });

			accounts = accounts.filter((acct) => acct.id !== id);
		} catch (error) {
			console.error('Failed to delete password:', error);
		}
	}

	// Save account state (create or update)
	async function handle_account_entry_save(account: Partial<AccountEntry>) {
		try {
			if (editingAccount) { //When updating
				const token = env.PUBLIC_OSTRICHDB_TOKEN;

				//Whatever change was made update over server
				if (editingAccount.username !== account.username) {
					await lib.handle_request(lib.RequestMethod.PUT, `${lib.ALL_ACCOUNTS}/${editingAccount.title}/records/username?value=${encodeURIComponent(account.username!)}`, token);
				}

				if (editingAccount.password !== account.password) {
					await lib.handle_request(lib.RequestMethod.PUT, `${lib.ALL_ACCOUNTS}/${editingAccount.title}/records/password?value=${encodeURIComponent(account.password!)}`, token);
				}

				if (editingAccount.email !== account.email) {
					if (account.email) {
						await lib.handle_request(lib.RequestMethod.PUT, `${lib.ALL_ACCOUNTS}/${editingAccount.title}/records/email?value=${encodeURIComponent(account.email)}`, token);
					}
				}

				if (editingAccount.url !== account.url) {
					if (account.url) {
						await lib.handle_request(lib.RequestMethod.PUT, `${lib.ALL_ACCOUNTS}/${editingAccount.title}/records/url?value=${encodeURIComponent(account.url)}`, token);
					}
				}

				if (editingAccount.notes !== account.notes) {
					if (account.notes) {
						await lib.handle_request(lib.RequestMethod.PUT, `${lib.ALL_ACCOUNTS}/${editingAccount.title}/records/notes?value=${encodeURIComponent(account.notes)}`, token);
					}
				}

				if (JSON.stringify(editingAccount.tags) !== JSON.stringify(account.tags)) {
					if (account.tags && account.tags.length > 0) {
						await lib.handle_request(lib.RequestMethod.PUT, `${lib.ALL_ACCOUNTS}/${editingAccount.title}/records/tags?value=[${account.tags}]`, token);
					}
				}


				accounts = accounts.map((entry) =>
					entry.id === editingAccount.id ? { ...entry, ...account, updatedAt: new Date() } : entry
				);
			} else {//Making new
				const token = env.PUBLIC_OSTRICHDB_TOKEN;
				//create the accounts cluster
				await lib.handle_request(lib.RequestMethod.POST, `${lib.ALL_ACCOUNTS}/${account.title}`, token)

				//Now append all info user entered (required fields)
				await lib.handle_request(lib.RequestMethod.POST, `${lib.ALL_ACCOUNTS}/${account.title}/records/username?type=STRING&value=${encodeURIComponent(account.username!)}`, token)
				await lib.handle_request(lib.RequestMethod.POST, `${lib.ALL_ACCOUNTS}/${account.title}/records/password?type=STRING&value=${encodeURIComponent(account.password!)}`, token)

				//handle optionals
				if (account.email) {
					await lib.handle_request(lib.RequestMethod.POST, `${lib.ALL_ACCOUNTS}/${account.title}/records/email?type=STRING&value=${encodeURIComponent(account.email)}`, token)
				}
				if (account.url) {
					await lib.handle_request(lib.RequestMethod.POST, `${lib.ALL_ACCOUNTS}/${account.title}/records/url?type=STRING&value=${encodeURIComponent(account.url)}`, token)
				}
				if (account.notes) {
					await lib.handle_request(lib.RequestMethod.POST, `${lib.ALL_ACCOUNTS}/${account.title}/records/notes?type=STRING&value=${encodeURIComponent(account.notes)}`, token)
				}
				if (account.tags && account.tags.length > 0) {
					await lib.handle_request(lib.RequestMethod.POST, `${lib.ALL_ACCOUNTS}/${account.title}/records/tags?type=[]STRING&value=[${account.tags}]`, token)
				}

				//Add the account to the account array state
				const newAccount: AccountEntry = {
					id: Date.now().toString(),
					...account,
					createdAt: new Date(),
					updatedAt: new Date()
				} as AccountEntry;

				accounts = [...accounts, newAccount];
			}

			showModal = false;
			editingAccount = null;
		} catch (error) {
			console.error('Failed to save password:', error);
		}
	}


	function toggle_passoword_show(id: string) {
		showPassword = { ...showPassword, [id]: !showPassword[id] };
	}

</script>

<div class="min-h-screen bg-slate-900">
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
						onclick={handle_logout}
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
					onclick={handle_adding_new_account_entry}
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
					{filteredAccounts.length} {filteredAccounts.length === 1 ? 'password' : 'passwords'}
					{searchQuery ? ' found' : ' stored'}
				</p>
			</div>

			<!-- Password Grid -->
			{#if filteredAccounts.length === 0}
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
					{#each filteredAccounts as account (account.id)}
						<AccountCard
							{account}
							isVisible={showPassword[account.id] || false}
							onToggleVisibility={() => toggle_passoword_show(account.id)}
							onEdit={() => handle_editing_account_entry(account)}
							onDelete={() => handle_deleting_account_entry(account.id)}
						/>
					{/each}
				</div>
			{/if}
		</div>
	</div>

	<!-- Password Modal -->
	{#if showModal}
		<AccountModal
			account={editingAccount}
			onSave={handle_account_entry_save}
			onClose={() => { showModal = false; editingAccount = null; }}
		/>
	{/if}
</div>
