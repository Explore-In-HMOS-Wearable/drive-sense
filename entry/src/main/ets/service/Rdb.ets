import { relationalStore } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import CommonConstantsDb from '../util/CommonConstantsDb';
import Logger from '../util/Logger';

export default class Rdb {
  private rdbStore: relationalStore.RdbStore | null = null;
  private tableName: string;
  private sqlCreateTable: string;
  private columns: Array<string>;
  private context: common.Context | null = null;

  constructor(tableName: string, sqlCreateTable: string, columns: Array<string>) {
    this.tableName = tableName;
    this.sqlCreateTable = sqlCreateTable;
    this.columns = columns;
  }

  setContext(context: common.Context): void {
    this.context = context;
  }

  executeSql(sql: string, callback?: (err?: Error) => void): void {
    if (!this.rdbStore) {
      Logger.error('❌ RDB store not initialized.')
      callback?.(new Error('RDB store is null'));
      return;
    }

    this.rdbStore.executeSql(sql, (err) => {
      if (err) {
        Logger.error('❌ SQL execution failed:')
        callback?.(err);
      } else {
        Logger.info('✅ SQL executed successfully')
        callback?.();
      }
    });
  }

  getRdbStore(callback: Function = () => {}) {
    if (!callback || typeof callback === 'undefined' || callback === undefined) {
      Logger.info(CommonConstantsDb.RDB_TAG, 'getRdbStore() has no callback!');
      return;
    }
    if (this.rdbStore !== null) {
      Logger.info(CommonConstantsDb.RDB_TAG, 'The rdbStore exists.');
      callback();
      return;
    }

    if (!this.context) {
      Logger.error(CommonConstantsDb.RDB_TAG, 'Context not set! Call setContext() first.');
      return;
    }

    relationalStore.getRdbStore(this.context, CommonConstantsDb.STORE_CONFIG, (err, rdb) => {
      if (err) {
        Logger.error(CommonConstantsDb.RDB_TAG, `gerRdbStore() failed, err: ${err.code}`);
        return;
      }
      this.rdbStore = rdb;
      this.rdbStore.executeSql(this.sqlCreateTable);
      Logger.info(CommonConstantsDb.RDB_TAG, 'getRdbStore() finished.');
      callback();
    });
  }

  insertData(data: relationalStore.ValuesBucket, callback: (success: boolean) => void = () => {}): void {
    if (!this.rdbStore) {
      callback(false);
      return;
    }
    this.rdbStore.insert(this.tableName, data, (err, result) => {
      if (err) {
        Logger.error('[RDB] Insert Error:');
        callback(false);
        return;
      }
      callback(true);
    });
  }

  deleteData(predicates: relationalStore.RdbPredicates, callback: Function = () => {}) {
    if (!callback || typeof callback === 'undefined' || callback === undefined) {
      Logger.info(CommonConstantsDb.RDB_TAG, 'deleteData() has no callback!');
      return;
    }
    let resFlag: boolean = false;
    if (this.rdbStore) {
      this.rdbStore.delete(predicates, (err, ret) => {
        if (err) {
          Logger.error(CommonConstantsDb.RDB_TAG, `deleteData() failed, err: ${err}`);
          callback(resFlag);
          return;
        }
        Logger.info(CommonConstantsDb.RDB_TAG, `deleteData() finished: ${ret}`);
        callback(!resFlag);
      });
    }
  }

updateData(predicat: relationalStore.RdbPredicates, data: relationalStore.ValuesBucket, call: Function = () => {}) {
    if (!call || typeof call === 'undefined' || call === undefined) {
      Logger.info(CommonConstantsDb.RDB_TAG, 'updateDate() has no call!');
      return;
    }
    let resFlag: boolean = false;
    const valueBucket: relationalStore.ValuesBucket = data;
    if (this.rdbStore) {
      this.rdbStore.update(valueBucket, predicat, (err, ret) => {
        if (err) {
          Logger.error(CommonConstantsDb.RDB_TAG, `updateData() failed, err: ${err}`);
          call(resFlag);
          return;
        }
        Logger.info(CommonConstantsDb.RDB_TAG, `updateData() finished: ${ret}`);
        call(!resFlag);
      });
    }
  }

  query(predicates: relationalStore.RdbPredicates, callback: Function = () => {}) {
    if (!callback || typeof callback === 'undefined' || callback === undefined) {
      Logger.info(CommonConstantsDb.RDB_TAG, 'query() has no callback!');
      return;
    }
    if (this.rdbStore) {
      this.rdbStore.query(predicates, this.columns, (err, resultSet) => {
        if (err) {
          Logger.error(CommonConstantsDb.RDB_TAG, `query() failed, err:  ${err}`);
          return;
        }
        Logger.info(CommonConstantsDb.RDB_TAG, 'query() finished.');
        callback(resultSet);
        resultSet.close();
      });
    }
  }
}