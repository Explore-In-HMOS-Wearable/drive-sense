import { DriveSummary } from '../model/DriveSummary';
import HistoryTable from '../service/HistoryTable';


@Observed
export class DriveSummaryViewModel {
  private favoriteTable: HistoryTable = new HistoryTable();

  public driveSummaries: DriveSummary[] = [];

  public driveSummaryCount: number = 0;

  getDriveSummary(callback?: () => void): void {
    this.favoriteTable.getAll((recipes: DriveSummary[]) => {
      this.driveSummaries = recipes;
      this.driveSummaryCount = recipes.length;
      if (callback){
        callback();
      }
    });
  }

  addDriveSummary(recipe: DriveSummary, callback: (success: boolean) => void): void {
    this.favoriteTable.insertFavorite(recipe, (success) => {
      if (success) {
        this.getDriveSummary();
      }
      callback(success);
    });
  }


  deleteDriveSummary(id: number, callback: (success: boolean) => void) {
    this.favoriteTable.deleteFavorite(id.toString(), callback);
  }


}
