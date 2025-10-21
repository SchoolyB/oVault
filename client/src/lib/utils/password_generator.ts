import type { GeneratedPasswordOptions } from "./common";

export function generate_password(options: GeneratedPasswordOptions): string {
  const {
    length,
    includeUppercase,
    includeLowercase,
    includeNumbers,
    includeSymbols
  } = options;

  //Valid chars
  const uppers = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const lowers = 'abcdefghijklmnopqrstuvwxyz';
  const nums = '0123456789';
  const specialChars = '!@#$%^&*()_+-=[]{}|;:,.<>?';

  //Create a 'pool' of chars from the possible chars above
  let charPool = '';
  if (includeUppercase) charPool += uppers;
  if (includeLowercase) charPool += lowers;
  if (includeNumbers) charPool += nums;
  if (includeSymbols) charPool += specialChars;


  // If no char types selected, use all
  if (charPool.length === 0) {
    charPool = uppers + lowers + nums + specialChars;
  }

  // Generate password using crypto.getRandomValues
  let password = '';
  const randomValues = new Uint32Array(length);
  crypto.getRandomValues(randomValues);

  for (let i = 0; i < length; i++) {
    const randomIndex = randomValues[i] % charPool.length;
    password += charPool[randomIndex];
  }

  //Improve generated password strength by making sure least one character from each selected type is used
  let hasRequiredChars = true;
  if (includeUppercase && !new RegExp(`[${uppers}]`).test(password)) {
    hasRequiredChars = false;
  }

  if (includeLowercase && !new RegExp(`[${lowers}]`).test(password)) {
    hasRequiredChars = false;
  }

  if (includeNumbers && !new RegExp(`[${nums}]`).test(password)) {
    hasRequiredChars = false;
  }

  if (includeSymbols && !new RegExp(`[${specialChars.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}]`).test(password)) {
    hasRequiredChars = false;
  }

	//If password doesn't have required chars of each selected type generate again
	if (hasRequiredChars == false && length >= 4) {
		return generate_password(options);
	}

	return password;
}

export function check_password_strength(password: string): {
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
