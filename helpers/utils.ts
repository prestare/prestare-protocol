import low from 'lowdb';
import FileSync from 'lowdb/adapters/FileSync';

export const getDb = () => low(new FileSync('./deployed-contracts.json'));