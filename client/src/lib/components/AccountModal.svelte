<script lang="ts">
	import { generate_password } from '$lib/utils/password_generator';
	import type { AccountCreationModalProps } from '$lib/utils/common';

	let { account, onSave, onClose }: AccountCreationModalProps = $props();

	//State for the account creation form
	let title = $state(account?.title || '');
	let email = $state(account?.email || '');
	let username = $state(account?.username || '');
	let accountPasswordValue = $state(account?.password || '');
	let url = $state(account?.url || '');
	let notes = $state(account?.notes || '');
	let tags = $state(account?.tags || '');
	let showPassword = $state(false);
	let showGenerator = $state(false);

	// Password generator options
	let generatorLength = $state(16);
	let includeUppercase = $state(true);
	let includeLowercase = $state(true);
	let includeNumbers = $state(true);
	let includeSymbols = $state(true);

	//This handles the actual submission of an new account entry over the server
	function handle_submit() {
		if (!title || !username || !accountPasswordValue) {
			alert('Please fill in all required fields');
			return;
		}

		onSave({
			title,
			email: email || undefined,
			username,
			password: accountPasswordValue,
			url: url || undefined,
			notes: notes || undefined
		});
	}

	function handle_password_generation() {
		const generated = generate_password({
			length: generatorLength,
			includeUppercase,
			includeLowercase,
			includeNumbers,
			includeSymbols
		});
		accountPasswordValue = generated;
		showGenerator = false;
	}

	function handle_modal_click_out(e: MouseEvent) {
		if (e.target === e.currentTarget) {
			onClose();
		}
	}

</script>

<!-- Modal Backdrop -->
<div
	class="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4"
	onclick={handle_modal_click_out}
	role="presentation"
>
	<!-- Modal Content -->
	<div class="bg-slate-800 rounded-2xl shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto border border-slate-700">
		<!-- Header -->
		<div class="sticky top-0 bg-slate-800 border-b border-slate-700 px-6 py-4 flex items-center justify-between">
			<h2 class="text-2xl font-bold text-white">
				{account ? 'Edit Account' : 'Add New Account'}
			</h2>
			<button
				onclick={onClose}
				class="p-2 hover:bg-slate-700 rounded-lg transition text-slate-400 hover:text-white"
			>
				<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
				</svg>
			</button>
		</div>

		<!-- Form -->
		<form onsubmit={(e) => { e.preventDefault(); handle_submit(); }} class="p-6 space-y-5">
			<!-- Title -->
			<div>
				<label for="title" class="block text-sm font-medium text-slate-300 mb-2">
					Title <span class="text-red-400">*</span>
				</label>
				<input
					id="title"
					type="text"
					bind:value={title}
					placeholder="e.g., GitHub, Gmail, Netflix"
					class="w-full px-4 py-3 bg-slate-900/50 border border-slate-600 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent outline-none text-white placeholder-slate-500 transition"
					required
				/>
			</div>

			<!-- URL -->
			<div>
				<label for="url" class="block text-sm font-medium text-slate-300 mb-2">
					Website URL
				</label>
				<input
					id="url"
					type="url"
					bind:value={url}
					placeholder="https://example.com"
					class="w-full px-4 py-3 bg-slate-900/50 border border-slate-600 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent outline-none text-white placeholder-slate-500 transition"
				/>
			</div>

			<!-- Email -->
			<div>
				<label for="email" class="block text-sm font-medium text-slate-300 mb-2">
					Email
				</label>
				<input
					id="email"
					type="email"
					bind:value={email}
					placeholder="user@example.com"
					class="w-full px-4 py-3 bg-slate-900/50 border border-slate-600 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent outline-none text-white placeholder-slate-500 transition"
					autocomplete="off"
				/>
			</div>

			<!-- Username -->
			<div>
				<label for="username" class="block text-sm font-medium text-slate-300 mb-2">
					Username <span class="text-red-400">*</span>
				</label>
				<input
					id="username"
					type="text"
					bind:value={username}
					placeholder="username or email"
					class="w-full px-4 py-3 bg-slate-900/50 border border-slate-600 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent outline-none text-white placeholder-slate-500 transition"
					required
					autocomplete="off"
				/>
			</div>

			<!-- Password -->
			<div>
				<label for="password" class="block text-sm font-medium text-slate-300 mb-2">
					Password <span class="text-red-400">*</span>
				</label>
				<div class="relative">
					<input
						id="password"
						type={showPassword ? 'text' : 'password'}
						bind:value={accountPasswordValue}
						placeholder="Enter password"
						class="w-full px-4 py-3 pr-24 bg-slate-900/50 border border-slate-600 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent outline-none text-white placeholder-slate-500 transition font-mono"
						required
						autocomplete="new-password"
					/>
					<div class="absolute right-2 top-1/2 transform -translate-y-1/2 flex items-center space-x-1">
						<button
							type="button"
							onclick={() => showPassword = !showPassword}
							class="p-2 hover:bg-slate-700 rounded-lg transition"
							title={showPassword ? 'Hide password' : 'Show password'}
						>
							{#if showPassword}
								<svg class="w-4 h-4 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21" />
								</svg>
							{:else}
								<svg class="w-4 h-4 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
								</svg>
							{/if}
						</button>
						<button
							type="button"
							onclick={() => showGenerator = !showGenerator}
							class="p-2 hover:bg-slate-700 rounded-lg transition"
							title="Generate password"
						>
							<svg class="w-4 h-4 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
								<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
							</svg>
						</button>
					</div>
				</div>

				<!-- Password Generator -->
				{#if showGenerator}
					<div class="mt-3 p-4 bg-slate-900/80 border border-slate-700 rounded-lg space-y-3">
						<div class="flex items-center justify-between">
							<label class="text-sm text-slate-300">Password Length: {generatorLength}</label>
						</div>
						<input
							type="range"
							bind:value={generatorLength}
							min="8"
							max="32"
							class="w-full accent-purple-500"
						/>

						<div class="grid grid-cols-2 gap-3">
							<label class="flex items-center space-x-2 cursor-pointer">
								<input
									type="checkbox"
									bind:checked={includeUppercase}
									class="w-4 h-4 rounded border-slate-600 bg-slate-800 text-purple-600 focus:ring-purple-500"
								/>
								<span class="text-sm text-slate-300">Uppercase (A-Z)</span>
							</label>
							<label class="flex items-center space-x-2 cursor-pointer">
								<input
									type="checkbox"
									bind:checked={includeLowercase}
									class="w-4 h-4 rounded border-slate-600 bg-slate-800 text-purple-600 focus:ring-purple-500"
								/>
								<span class="text-sm text-slate-300">Lowercase (a-z)</span>
							</label>
							<label class="flex items-center space-x-2 cursor-pointer">
								<input
									type="checkbox"
									bind:checked={includeNumbers}
									class="w-4 h-4 rounded border-slate-600 bg-slate-800 text-purple-600 focus:ring-purple-500"
								/>
								<span class="text-sm text-slate-300">Numbers (0-9)</span>
							</label>
							<label class="flex items-center space-x-2 cursor-pointer">
								<input
									type="checkbox"
									bind:checked={includeSymbols}
									class="w-4 h-4 rounded border-slate-600 bg-slate-800 text-purple-600 focus:ring-purple-500"
								/>
								<span class="text-sm text-slate-300">Symbols (!@#$)</span>
							</label>
						</div>

						<button
							type="button"
							onclick={handle_password_generation}
							class="w-full py-2 bg-purple-600 hover:bg-purple-700 text-white text-sm font-medium rounded-lg transition"
						>
							Generate Password
						</button>
					</div>
				{/if}
			</div>

			<!-- Notes -->
			<div>
				<label for="notes" class="block text-sm font-medium text-slate-300 mb-2 flex items-center justify-between">
					<span>Notes</span>
					<span class="text-xs {notes.length > 32 ? 'text-red-400' : 'text-slate-500'}">{notes.length}/32</span>
				</label>
				<textarea
					id="notes"
					bind:value={notes}
					placeholder="Additional notes (optional)"
					maxlength="32"
					rows="3"
					class="w-full px-4 py-3 bg-slate-900/50 border border-slate-600 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent outline-none text-white placeholder-slate-500 transition resize-none"
				></textarea>
			</div>

			<!-- Actions -->
			<div class="flex items-center justify-end space-x-3 pt-4 border-t border-slate-700">
				<button
					type="button"
					onclick={onClose}
					class="px-6 py-2.5 bg-slate-700 hover:bg-slate-600 text-white font-medium rounded-lg transition"
				>
					Cancel
				</button>
				<button
					type="submit"
					class="px-6 py-2.5 bg-purple-600 hover:bg-purple-700 text-white font-medium rounded-lg transition shadow-lg shadow-purple-500/30"
				>
					{account ? 'Update' : 'Add'} Account
				</button>
			</div>
		</form>
	</div>
</div>
