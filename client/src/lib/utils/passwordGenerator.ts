interface GeneratePasswordOptions {
	length: number;
	includeUppercase: boolean;
	includeLowercase: boolean;
	includeNumbers: boolean;
	includeSymbols: boolean;
}

export function generatePassword(options: GeneratePasswordOptions): string {
	const {
		length,
		includeUppercase,
		includeLowercase,
		includeNumbers,
		includeSymbols
	} = options;

	// Character sets
	const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	const lowercase = 'abcdefghijklmnopqrstuvwxyz';
	const numbers = '0123456789';
	const symbols = '!@#$%^&*()_+-=[]{}|;:,.<>?';

	// Build character pool based on options
	let charPool = '';
	if (includeUppercase) charPool += uppercase;
	if (includeLowercase) charPool += lowercase;
	if (includeNumbers) charPool += numbers;
	if (includeSymbols) charPool += symbols;

	// If no character types selected, use all
	if (charPool.length === 0) {
		charPool = uppercase + lowercase + numbers + symbols;
	}

	// Generate password using crypto.getRandomValues for secure randomness
	let password = '';
	const randomValues = new Uint32Array(length);
	crypto.getRandomValues(randomValues);

	for (let i = 0; i < length; i++) {
		const randomIndex = randomValues[i] % charPool.length;
		password += charPool[randomIndex];
	}

	// Ensure password contains at least one character from each selected type
	let hasRequiredChars = true;
	if (includeUppercase && !new RegExp(`[${uppercase}]`).test(password)) hasRequiredChars = false;
	if (includeLowercase && !new RegExp(`[${lowercase}]`).test(password)) hasRequiredChars = false;
	if (includeNumbers && !new RegExp(`[${numbers}]`).test(password)) hasRequiredChars = false;
	if (includeSymbols && !new RegExp(`[${symbols.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}]`).test(password)) hasRequiredChars = false;

	// If password doesn't have required character types, regenerate
	if (!hasRequiredChars && length >= 4) {
		return generatePassword(options);
	}

	return password;
}

export function calculatePasswordStrength(password: string): {
	score: number;
	label: string;
	color: string;
} {
	let score = 0;

	// Length check
	if (password.length >= 8) score += 1;
	if (password.length >= 12) score += 1;
	if (password.length >= 16) score += 1;

	// Character variety checks
	if (/[a-z]/.test(password)) score += 1;
	if (/[A-Z]/.test(password)) score += 1;
	if (/[0-9]/.test(password)) score += 1;
	if (/[^a-zA-Z0-9]/.test(password)) score += 1;

	// Determine label and color
	let label = 'Very Weak';
	let color = 'red';

	if (score >= 7) {
		label = 'Very Strong';
		color = 'green';
	} else if (score >= 5) {
		label = 'Strong';
		color = 'lime';
	} else if (score >= 4) {
		label = 'Good';
		color = 'yellow';
	} else if (score >= 2) {
		label = 'Weak';
		color = 'orange';
	}

	return { score, label, color };
}
