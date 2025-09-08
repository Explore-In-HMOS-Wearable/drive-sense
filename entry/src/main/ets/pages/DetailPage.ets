import { DriveSummary } from '../model/DriveSummary';
import { ConstantUI } from '../util/ConstantUI';

@Component
struct DetailPage {
  @Consume('NavPathStack') pageStack: NavPathStack
  @State data: DriveSummary = {
    id:0,
    brakeCount: 0,
    turnCount: 0,
    stopGoCount: 0,
    avgAccel: '0',
    badScore: 0
  }

  aboutToAppear() {
    this.data = this.pageStack.getParamByName('DetailPage')[0] as DriveSummary
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Text($r('app.string.drive_summary'))
            .fontSize($r('app.float.fp_title'))
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: ConstantUI.MARGIN_MEDIUM })


          this.statRow($r('app.string.hard_brake_count'), this.data.brakeCount.toString())
          this.statRow($r('app.string.sharp_turn_count'), this.data.turnCount.toString())
          this.statRow($r('app.string.stop_go_count'), this.data.stopGoCount.toString())
          this.statRow($r('app.string.average_accel'), this.data.avgAccel)
          this.statRow($r('app.string.total_penalty'), this.data.badScore.toString())


          Button($r('app.string.back_button'))
            .margin({ top: ConstantUI.MARGIN_TOP_LINK })
            .width(ConstantUI.FULL_WIDTH)
            .height(45)
            .backgroundColor(0x333333)
            .fontColor(Color.White)
            .fontSize($r('app.float.fp_button_font'))
            .borderRadius(ConstantUI.ITEM_RADIUS)
            .onClick(() => {
              this.pageStack.pushPathByName('Index', null, true)
            })

          Button($r('app.string.history_button'))
            .margin({ top: ConstantUI.MARGIN_MEDIUM })
            .width(ConstantUI.FULL_WIDTH)
            .height(45)
            .backgroundColor(0x555555)
            .fontColor(Color.White)
            .fontSize($r('app.float.fp_button_font'))
            .borderRadius(ConstantUI.ITEM_RADIUS)
            .onClick(() => {
              this.pageStack.pushPathByName('HistoryPage', null, true)
            })
        }
        .padding(ConstantUI.PADDING_MEDIUM)
      }
      .width(ConstantUI.FULL_WIDTH)
      .height(ConstantUI.FULL_HEIGHT)
      .backgroundColor(Color.Black)
      .scrollable(ScrollDirection.Vertical)
    }
    .onBackPressed(() => {
      this.pageStack.replacePathByName('Index',true)
      return true
    })
    .width(ConstantUI.FULL_WIDTH)
    .height(ConstantUI.FULL_HEIGHT)
    .hideTitleBar(true)
  }

  @Builder
  private statRow(label: Resource, value: string) {
    Row() {
      Text(label)
        .fontSize($r('app.float.fp_text_value'))
        .fontColor(0xDDDDDD)
        .layoutWeight(1)

      Text(value)
        .fontSize($r('app.float.fp_text_value'))
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium)
    }
    .width(ConstantUI.FULL_WIDTH)
    .margin({ bottom: ConstantUI.MARGIN_BOTTOM_VERSION })
  }

}
@Builder
export function DetailPageBuilder() {
  DetailPage()
}