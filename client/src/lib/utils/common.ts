//Constants
export const BASE_URL = 'http://localhost:8042/api/v1';
export const CREDENDIAL_PROJECT = "/projects/secure"
export const CREDENTIAL_COLLECTION = "/projects/secure/collections/credentials"
export const CREDENTIAL_CLUSTER = "/projects/secure/collections/credentials/clusters/creds"
export const USERNAME_RECORD = "/projects/secure/collections/credentials/clusters/creds/records/username"
export const PASSWORD_RECORD = "/projects/secure/collections/credentials/clusters/creds/records/password"
export const USERNAME_RECORD_VALUE = "/projects/secure/collections/credentials/clusters/creds/records/username?type=string&value="
export const ACCOUNTS_COLLECTION = "/projects/secure/collections/accounts"
export const ALL_ACCOUNTS = "/projects/secure/collections/accounts/clusters"



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

export interface OstrichDBRecord {
		id: string;
		name: string;
		type: string;
		value: string;
	}

	export enum RequestMethod{
    GET = 0,
    POST = 1,
    DELETE  = 2,
    PUT = 3
	}

	//Just a helper to get str val of enum. TS aint so bad i guess.
export function handle_method(reqType: RequestMethod): string {
  switch (reqType) {
    case RequestMethod.GET:
      return "GET";
    case RequestMethod.POST:
      return "POST";
    case RequestMethod.DELETE:
      return "DELETE";
    case RequestMethod.PUT:
      return "PUT";
    default:
      throw new Error('Unhandled method passed');
  }
}

	export async function handle_request(reqType: RequestMethod, url: string, token: string | undefined): Promise<Response> {

	const response = await fetch(
		`${BASE_URL}${url}`,
		{
			method: handle_method(reqType),
			headers: {
				Authorization: `Bearer ${token}`,
				'Content-Type': 'application/json',
				Accept: 'application/json'
			}
		}
	);

	return response
}

export async function store_registration_creds(recordName: string, value: string, token: string | undefined) {
    await fetch(`${BASE_URL}/projects/secure/collections/credentials/clusters/creds/records/${recordName}?type=string&value=${encodeURIComponent(value)}`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': `application/json`,
        'Accept': `application/json`
      }
    });

  return true
}