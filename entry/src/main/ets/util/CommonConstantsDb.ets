import { relationalStore } from '@kit.ArkData';

export interface TableDefinition {
  tableName: string;
  sqlCreate: string;
  columns: string[];
}

export default class CommonConstantsDb {
  static readonly STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'favorites.db',
    securityLevel: relationalStore.SecurityLevel.S1
  };
  
  static readonly DRIVE_SUMMARY_TABLE: TableDefinition = {
    tableName: 'driveSummaryTable',
    sqlCreate: `CREATE TABLE IF NOT EXISTS driveSummaryTable (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      brakeCount INTEGER,
      turnCount INTEGER,
      stopGoCount INTEGER,
      avgAccel TEXT,
      badScore INTEGER
    )`,
    columns: ['id', 'brakeCount', 'turnCount', 'stopGoCount', 'avgAccel', 'badScore']
  };

  static readonly RDB_TAG = '[Debug.Rdb]';
  static readonly TABLE_TAG = '[Debug.AccountTable]';
  static readonly INDEX_TAG = '[Debug.Index]';
}
