import { DriveSummary } from '../model/DriveSummary';
import { ConstantUI } from '../util/ConstantUI';
import { DriveSummaryViewModel } from '../viewmodel/DriveSummaryViewModel';

@Component
struct HistoryPage {
  @Consume('NavPathStack') pageStack: NavPathStack
  private viewModel: DriveSummaryViewModel = new DriveSummaryViewModel();
  @State private driveSummaries: DriveSummary[] = []
  private scroller: ListScroller = new ListScroller()

  aboutToAppear(): void {
    this.viewModel.getDriveSummary(() => {
      this.driveSummaries = this.viewModel.driveSummaries.reverse();
    });
  }

  @Builder
  itemEnd(id: number) {
    Button($r('app.string.delete'))
      .height(ConstantUI.FULL_HEIGHT)
      .backgroundColor(Color.Red)
      .fontColor(Color.White)
      .borderRadius(ConstantUI.ITEM_RADIUS)
      .type(ButtonType.Normal)
      .fontWeight(FontWeight.Bold)
      .onClick(() => {
        this.viewModel.deleteDriveSummary(id, (success: boolean) => {
          if (success) {
            this.scroller.closeAllSwipeActions()
            this.viewModel.getDriveSummary(() => {
              this.driveSummaries = this.viewModel.driveSummaries.reverse()
            });
          }
        });
      })
  }

  build() {
    NavDestination() {
      Column() {
        Text($r('app.string.history_button'))
          .fontSize($r('app.float.fp_title'))
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ top: ConstantUI.MARGIN_TOP_LINK,
            bottom: ConstantUI.MARGIN_BOTTOM_VERSION,
            left: ConstantUI.MARGIN_BOTTOM_VERSION })

        List({scroller:this.scroller}) {
          ForEach(this.driveSummaries, (summary: DriveSummary) => {
            ListItem() {
              Column() {
                this.statRow($r('app.string.hard_brake_count'), summary.brakeCount.toString())
                this.statRow($r('app.string.sharp_turn_count'), summary.turnCount.toString())
                this.statRow($r('app.string.stop_go_count'), summary.stopGoCount.toString())
                this.statRow($r('app.string.average_accel'), summary.avgAccel)
                this.statRow($r('app.string.total_penalty'), summary.badScore.toString())
              }
              .padding(ConstantUI.PADDING_SMALL)
              .backgroundColor(this.getCardColor(summary.badScore))
              .borderRadius(ConstantUI.ITEM_RADIUS)
              .shadow({ radius: 4, color: '#00000022', offsetX: 0, offsetY: 2 })
            }
            .transition({ type: TransitionType.Delete, opacity: 0 })
            .swipeAction({
              end: {
                builder: () => this.itemEnd(summary.id),
                onAction: () => {
                  animateTo({ duration: ConstantUI.LONG_DURATION }, () => {
                    this.viewModel.deleteDriveSummary(summary.id, (success: boolean) => {
                      if (success) {
                      animateTo({duration:ConstantUI.LONG_DURATION},() => {
                        this.viewModel.getDriveSummary(() => {
                          this.driveSummaries = this.viewModel.driveSummaries.reverse();
                        });
                      })
                      }
                    });
                  })
                },
                actionAreaDistance:56
              }
            })
            .margin({ bottom: 12, left: ConstantUI.MARGIN_BOTTOM_VERSION, right: ConstantUI.MARGIN_BOTTOM_VERSION })
          }, (item: DriveSummary) => item.id.toString())
        }
        .width(ConstantUI.FULL_WIDTH)
      }
    }
    .hideTitleBar(true)
    .height(ConstantUI.FULL_HEIGHT)
    .width(ConstantUI.FULL_WIDTH)
    .backgroundColor($r('app.color.history_background'))
  }

  @Builder
  private statRow(label: Resource, value: string) {
    Row() {
      Text(label)
        .fontSize($r('app.float.fp_text_value'))
        .fontColor($r('app.color.text_value_label'))
        .layoutWeight(1)

      Text(value)
        .fontSize($r('app.float.fp_text_value'))
        .fontColor(Color.Black)
        .fontWeight(FontWeight.Bold)
    }
    .width(ConstantUI.FULL_WIDTH)
    .margin({ bottom: ConstantUI.MARGIN_SMALL })
  }

  private getCardColor(score: number): Color {
    if (score <= 10) {
       return 0xFF10B981
    }
    if (score <= 20) {
       return 0xFFFBBF24
    }
    if (score <= 30) {
      return 0xFFF97316
    }
    if (score <= 40) {
      return 0xFFEF4444
    }
    return 0xFF7F1D1D
  }
}

@Builder
export function HistoryPageBuilder() {
  HistoryPage()
}