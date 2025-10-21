//Types
export interface AccountEntry {
	id: string;
	title: string;
	username: string;
	password: string;
	url?: string;
	notes?: string;
	createdAt: Date;
	updatedAt: Date;
	tags: string[];
}

export interface AccountCreationModalProps {
	account: AccountEntry | null;
	onSave: (account: Partial<AccountEntry>) => void;
	onClose: () => void;
}

export	interface AccountCardProps {
	account: AccountEntry;
	isVisible: boolean;
	onToggleVisibility: () => void;
	onEdit: () => void;
	onDelete: () => void;
}

export interface GeneratedPasswordOptions {
	length: number;
	includeUppercase: boolean;
	includeLowercase: boolean;
	includeNumbers: boolean;
	includeSymbols: boolean;
}