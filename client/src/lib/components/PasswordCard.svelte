<script lang="ts">
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

	interface Props {
		password: PasswordEntry;
		isVisible: boolean;
		onToggleVisibility: () => void;
		onEdit: () => void;
		onDelete: () => void;
	}

	let { password, isVisible, onToggleVisibility, onEdit, onDelete }: Props = $props();

	let copied = $state(false);

	async function copyPassword() {
		try {
			await navigator.clipboard.writeText(password.password);
			copied = true;
			setTimeout(() => {
				copied = false;
			}, 2000);
		} catch (error) {
			console.error('Failed to copy password:', error);
		}
	}

	async function copyUsername() {
		try {
			await navigator.clipboard.writeText(password.username);
		} catch (error) {
			console.error('Failed to copy username:', error);
		}
	}

	function getFavicon(url?: string) {
		if (!url) return null;
		try {
			const domain = new URL(url).hostname;
			return `https://www.google.com/s2/favicons?domain=${domain}&sz=64`;
		} catch {
			return null;
		}
	}
</script>

<div class="bg-slate-800/50 backdrop-blur border border-slate-700 rounded-xl p-5 hover:border-purple-500/50 transition-all duration-200 group">
	<!-- Header with Icon and Actions -->
	<div class="flex items-start justify-between mb-4">
		<div class="flex items-center space-x-3">
			{#if password.url && getFavicon(password.url)}
				<img
					src={getFavicon(password.url)}
					alt=""
					class="w-10 h-10 rounded-lg"
					onerror={(e) => e.currentTarget.style.display = 'none'}
				/>
			{:else}
				<div class="w-10 h-10 bg-gradient-to-br from-purple-600 to-blue-600 rounded-lg flex items-center justify-center">
					<span class="text-white font-bold text-lg">{password.title.charAt(0).toUpperCase()}</span>
				</div>
			{/if}
			<div class="flex-1 min-w-0">
				<h3 class="text-white font-semibold text-lg truncate">{password.title}</h3>
				{#if password.url}
					<a
						href={password.url}
						target="_blank"
						rel="noopener noreferrer"
						class="text-sm text-purple-400 hover:text-purple-300 truncate block"
					>
						{new URL(password.url).hostname}
					</a>
				{/if}
			</div>
		</div>

		<!-- Action Buttons -->
		<div class="flex items-center space-x-1 opacity-0 group-hover:opacity-100 transition-opacity">
			<button
				onclick={onEdit}
				class="p-2 hover:bg-slate-700 rounded-lg transition text-slate-400 hover:text-white"
				title="Edit"
			>
				<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
				</svg>
			</button>
			<button
				onclick={onDelete}
				class="p-2 hover:bg-red-500/20 rounded-lg transition text-slate-400 hover:text-red-400"
				title="Delete"
			>
				<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
				</svg>
			</button>
		</div>
	</div>

	<!-- Username -->
	<div class="mb-3">
		<label class="text-xs text-slate-400 mb-1 block">Username</label>
		<div class="flex items-center justify-between bg-slate-900/50 rounded-lg px-3 py-2 group/username">
			<span class="text-white text-sm truncate flex-1">{password.username}</span>
			<button
				onclick={copyUsername}
				class="ml-2 p-1 hover:bg-slate-700 rounded transition opacity-0 group-hover/username:opacity-100"
				title="Copy username"
			>
				<svg class="w-4 h-4 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
				</svg>
			</button>
		</div>
	</div>

	<!-- Password -->
	<div>
		<label class="text-xs text-slate-400 mb-1 block">Password</label>
		<div class="flex items-center justify-between bg-slate-900/50 rounded-lg px-3 py-2">
			<span class="text-white text-sm font-mono flex-1 truncate">
				{isVisible ? password.password : '••••••••••••'}
			</span>
			<div class="flex items-center space-x-1 ml-2">
				<button
					onclick={onToggleVisibility}
					class="p-1 hover:bg-slate-700 rounded transition"
					title={isVisible ? 'Hide password' : 'Show password'}
				>
					{#if isVisible}
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
					onclick={copyPassword}
					class="p-1 hover:bg-slate-700 rounded transition relative"
					title="Copy password"
				>
					{#if copied}
						<svg class="w-4 h-4 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
						</svg>
					{:else}
						<svg class="w-4 h-4 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
						</svg>
					{/if}
				</button>
			</div>
		</div>
	</div>

	<!-- Notes (if present) -->
	{#if password.notes}
		<div class="mt-3 pt-3 border-t border-slate-700">
			<p class="text-xs text-slate-400 line-clamp-2">{password.notes}</p>
		</div>
	{/if}
</div>
