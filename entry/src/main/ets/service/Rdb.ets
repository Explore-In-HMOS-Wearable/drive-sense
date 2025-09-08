import { relationalStore } from '@kit.ArkData';
import CommonConstantsDb from '../util/CommonConstantsDb';
import Logger from '../util/Logger';

export default class Rdb {
  private rdbStore: relationalStore.RdbStore | null = null;
  private tableName: string;
  private sqlCreateTable: string;
  private columns: Array<string>;

  constructor(tableName: string, sqlCreateTable: string, columns: Array<string>) {
    this.tableName = tableName;
    this.sqlCreateTable = sqlCreateTable;
    this.columns = columns;
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

  getRdbStore(callback: Function = () => {
  }) {
    if (!callback || typeof callback === 'undefined' || callback === undefined) {
      Logger.info(CommonConstantsDb.RDB_TAG, 'getRdbStore() has no callback!');
      return;
    }
    if (this.rdbStore !== null) {
      Logger.info(CommonConstantsDb.RDB_TAG, 'The rdbStore exists.');
      callback();
      return
    }
    let context = getContext(this) as Context;
    relationalStore.getRdbStore(context, CommonConstantsDb.STORE_CONFIG, (err, rdb) => {
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
    if (!this.rdbStore) {return;}
    this.rdbStore.insert(this.tableName, data, (err, result) => {
      if (err) {
        Logger.error('[RDB] Insert Error:');
        callback(false);
        return;
      }
      callback(true);
    });
  }


  deleteData(predicates: relationalStore.RdbPredicates, callback: Function = () => {
  }) {
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

  updateData(predicates: relationalStore.RdbPredicates, data: relationalStore.ValuesBucket, callback: Function = () => {
  }) {
    if (!callback || typeof callback === 'undefined' || callback === undefined) {
      Logger.info(CommonConstantsDb.RDB_TAG, 'updateDate() has no callback!');
      return;
    }
    let resFlag: boolean = false;
    const valueBucket: relationalStore.ValuesBucket = data;
    if (this.rdbStore) {
      this.rdbStore.update(valueBucket, predicates, (err, ret) => {
        if (err) {
          Logger.error(CommonConstantsDb.RDB_TAG, `updateData() failed, err: ${err}`);
          callback(resFlag);
          return;
        }
        Logger.info(CommonConstantsDb.RDB_TAG, `updateData() finished: ${ret}`);
        callback(!resFlag);
      });
    }
  }

  query(predicates: relationalStore.RdbPredicates, callback: Function = () => {
  }) {
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