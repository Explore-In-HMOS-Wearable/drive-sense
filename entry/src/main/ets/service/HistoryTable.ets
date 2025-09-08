import { relationalStore } from '@kit.ArkData';
import { DriveSummary } from '../model/DriveSummary';
import CommonConstantsDb from '../util/CommonConstantsDb';
import Rdb from './Rdb';
import Logger from '../util/Logger';

export default class FavoriteTable {
  private table = new Rdb(
    CommonConstantsDb.DriveSummary_Table.tableName,
    CommonConstantsDb.DriveSummary_Table.sqlCreate,
    CommonConstantsDb.DriveSummary_Table.columns
  );

  constructor(callback: Function = () => {}) {
    this.table.getRdbStore(callback);
  }
  clearAll(callback: (success: boolean) => void) {
    const predicates = new relationalStore.RdbPredicates(CommonConstantsDb.DriveSummary_Table.tableName);
    this.table.deleteData(predicates, callback);
  }
  getRdbStore(callback: Function = () => {}) {
    this.table.getRdbStore(callback);
  }
  dropTable(callback: (success: boolean) => void) {
    this.getRdbStore(() => {
      const sql = `DROP TABLE IF EXISTS ${CommonConstantsDb.DriveSummary_Table.tableName}`;
      this.table.executeSql(sql, (err?: Error) => {
        if (err) {

          Logger.error('❌ Failed to drop table:');
          callback(false);
        } else {
          Logger.info('🧨 Table dropped.');
          callback(true);
        }
      });
    });
  }

  getCount(callback: (count: number) => void) {
    this.getRdbStore(() => {
      const predicates = new relationalStore.RdbPredicates(CommonConstantsDb.DriveSummary_Table.tableName);
      this.table.query(predicates, (resultSet: relationalStore.ResultSet | null) => {
        if (!resultSet) {
          callback(0);
          return;
        }
        callback(resultSet.rowCount);
      });
    });
  }

  insertFavorite(recipe: DriveSummary, callback: (success: boolean) => void) {
    this.getAll((recipes: DriveSummary[]) => {
      const valueBucket: relationalStore.ValuesBucket = {
        brakeCount: recipe.brakeCount,
        turnCount: recipe.turnCount,
        stopGoCount: recipe.stopGoCount,
        avgAccel: recipe.avgAccel,
        badScore: recipe.badScore
      };

      this.getRdbStore(() => {
        this.table.insertData(valueBucket, callback);
      });
    });
  }

  deleteFavorite(id: string, callback: (success: boolean) => void) {
    const predicates = new relationalStore.RdbPredicates(CommonConstantsDb.DriveSummary_Table.tableName);
    predicates.equalTo('id', id);
    this.table.deleteData(predicates, callback);
  }

  getAll(callback: (recipes: DriveSummary[]) => void) {
    this.getRdbStore(() => {
      const predicates = new relationalStore.RdbPredicates(CommonConstantsDb.DriveSummary_Table.tableName);
      this.table.query(predicates, (resultSet: relationalStore.ResultSet | null) => {
        if (!resultSet || resultSet.rowCount === 0) {
          callback([]);
          return;
        }

        const results: DriveSummary[] = [];
        resultSet.goToFirstRow();
        for (let i = 0; i < resultSet.rowCount; i++) {
          results.push({
            id: Number(resultSet.getLong(resultSet.getColumnIndex('id'))),
            brakeCount: Number(resultSet.getLong(resultSet.getColumnIndex('brakeCount'))),
            turnCount: Number(resultSet.getLong(resultSet.getColumnIndex('turnCount'))),
            stopGoCount: Number(resultSet.getLong(resultSet.getColumnIndex('stopGoCount'))),
            avgAccel: resultSet.getString(resultSet.getColumnIndex('avgAccel')),
            badScore: Number(resultSet.getLong(resultSet.getColumnIndex('badScore')))
          });

          resultSet.goToNextRow();
        }
        callback(results);
      });
    });
  }
}
