import { ConstantUI, ConstantUI as UI } from '../util/ConstantUI'
import { sensor } from '@kit.SensorServiceKit'
import { backgroundTaskManager } from '@kit.BackgroundTasksKit'
import { wantAgent, common } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { DriveSummary } from '../model/DriveSummary'
import { DriveSummaryViewModel } from '../viewmodel/DriveSummaryViewModel'
import Logger from '../util/Logger';

@Component
struct Index {
  @Consume('NavPathStack') pageStack: NavPathStack

  @State private isDriving: boolean = false
  @State private scaleValue: number = 1

  @State private showBrakeAnim: boolean = false
  @State private showTurnAnim: boolean = false
  @State private showStopGoAnim: boolean = false

  private accelX: number = 0
  private accelY: number = 0
  private accelZ: number = 0
  private gyroY: number = 0
  private badScore: number = 0
  private brakeCount: number = 0
  private driveId:number = 0
  private turnCount: number = 0
  private stopGoCount: number = 0
  private lastAccelZ: number = 0
  private accelSum: number = 0
  private accelSamples: number = 0
  private scoreTimer: number = 0
  private lastLogTime: number = Date.now()

  private viewModel: DriveSummaryViewModel = new DriveSummaryViewModel()
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  aboutToDisappear() {
    if (this.isDriving) {
      this.stopDrive()
    }
  }

  private async startBackgroundRunning() {
    const info: wantAgent.WantAgentInfo = {
      wants: [{
        bundleName: this.context.abilityInfo.bundleName,
        abilityName: this.context.abilityInfo.name
      }],
      operationType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    }

    try {
      const agent = await wantAgent.getWantAgent(info)
      await backgroundTaskManager.startBackgroundRunning(
        this.context,
        backgroundTaskManager.BackgroundMode.DATA_TRANSFER,
        agent
      )
    } catch (e) {
      Logger.error('startBackgroundRunning error: ' + JSON.stringify(e))
    }
  }

  private async stopBackgroundRunning() {
    try {
      await backgroundTaskManager.stopBackgroundRunning(this.context)
    } catch (e) {
      Logger.error('stopBackgroundRunning error: ' + JSON.stringify(e))
    }
  }


  private startSensors() {
    try {
      sensor.on(sensor.SensorId.ACCELEROMETER, (d) => {
        this.accelX = d.x
        this.accelY = d.y
        this.accelZ = d.z
      }, { interval: 10_000_000 })

      sensor.on(sensor.SensorId.GYROSCOPE, (d) => {
        this.gyroY = Math.abs(d.y)

        const now = Date.now()
        if (now - this.lastLogTime > 3000) {
          Logger.info(`GyroY: ${d.y.toFixed(4)}`)
          this.lastLogTime = now
        }

      }, { interval: 10_000_000 })
    } catch (err) {
      const e: BusinessError = err as BusinessError
      Logger.error(`Sensor error: ${e.code} / ${e.message}`)
    }
  }

  private stopSensors() {
    try {
      sensor.off(sensor.SensorId.ACCELEROMETER)
      sensor.off(sensor.SensorId.GYROSCOPE)
    } catch (err) {
      Logger.error('Sensor off error: ' + JSON.stringify(err))
    }
  }

  private startScoreTimer() {
    this.badScore = 0
    this.brakeCount = 0
    this.turnCount = 0
    this.stopGoCount = 0
    this.accelSum = 0
    this.accelSamples = 0
    this.lastAccelZ = this.accelZ

    this.scoreTimer = setInterval(() => {
      const totalAccel = Math.sqrt(this.accelX ** 2 + this.accelY ** 2 + this.accelZ ** 2)

      if (totalAccel > 15) {
        this.badScore += 10
        this.brakeCount++
        this.showBrakeAnim = true
        setTimeout(() => this.showBrakeAnim = false, 1000)
      }

      if (this.gyroY > 2) {
        this.badScore += 5
        this.turnCount++
        this.showTurnAnim = true
        setTimeout(() => this.showTurnAnim = false, 1000)
      }

      if (this.lastAccelZ < 1 && this.accelZ > 5) {
        this.stopGoCount++
        this.showStopGoAnim = true
        setTimeout(() => this.showStopGoAnim = false, 1000)
      }

      this.lastAccelZ = this.accelZ
      this.accelSum += totalAccel
      this.accelSamples++
    }, 5_000) as number
  }

  private stopScoreTimer() {
    if (this.scoreTimer !== 0) {
      clearInterval(this.scoreTimer)
      this.scoreTimer = 0
    }
  }

  private shrinkBtn() {
    animateTo({ duration: UI.DURATION, curve: Curve.Ease }, () => {
      this.scaleValue = UI.SCALE_DOWN
    })
  }

  private restoreBtn() {
    animateTo({ duration: UI.DURATION, curve: Curve.Ease }, () => {
      this.scaleValue = 1
    })
  }

  private startDrive() {
    this.shrinkBtn()
    setTimeout(() => {
      this.isDriving = true
      this.restoreBtn()
      this.startBackgroundRunning()
      this.startSensors()
      this.startScoreTimer()
    }, UI.DURATION)
  }

  private stopDrive() {
    this.shrinkBtn()

    const avgAccel = this.accelSamples > 0 ?
    (this.accelSum / this.accelSamples).toFixed(2) :
      '0';


    const driveSummary: DriveSummary = {
      id:this.driveId,
      brakeCount: this.brakeCount,
      turnCount: this.turnCount,
      stopGoCount: this.stopGoCount,
      avgAccel: avgAccel,
      badScore: this.badScore
    }

    setTimeout(() => {
      this.isDriving = false
      this.restoreBtn()
      this.stopScoreTimer()
      this.stopSensors()
      this.stopBackgroundRunning()

      this.viewModel.addDriveSummary(driveSummary, (success) => {
      })

      this.pageStack.clear()
      this.pageStack.pushPathByName('DetailPage', driveSummary, false)
    }, UI.DURATION)
  }

  build() {
    NavDestination() {
      Column() {

        if (this.showBrakeAnim) {
          Text($r('app.string.alert_hard_brake'))
            .fontSize($r('app.float.fp_warning_msg'))
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Red)
            .margin({ bottom: ConstantUI.MARGIN_BOTTOM_VERSION })
            .animation({ duration: 300, curve: Curve.EaseInOut })
        }

        if (this.showTurnAnim) {
          Text($r('app.string.sharp_turn_count'))
            .fontSize($r('app.float.fp_warning_msg'))
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Yellow)
            .margin({ bottom: ConstantUI.MARGIN_BOTTOM_VERSION })
            .animation({ duration: 300, curve: Curve.EaseInOut })
        }

        if (this.showStopGoAnim) {
          Text($r('app.string.alert_stop_go'))
            .fontSize($r('app.float.fp_warning_msg'))
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Orange)
            .margin({ bottom: ConstantUI.MARGIN_BOTTOM_VERSION })
            .animation({ duration: 300, curve: Curve.EaseInOut })
        }

        Text($r('app.string.drive_sense'))
          .fontSize($r('app.float.fp_title'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .margin({ top: UI.MARGIN_TOP_HEADER, bottom: UI.MARGIN_BOTTOM_HEADER })

        Text($r('app.string.analyze'))
          .fontSize($r('app.float.fp_text'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ bottom: UI.MARGIN_BOTTOM_TAGLINE })

        Button(this.isDriving ? 'Stop Driving' : 'Start Driving')
          .width(UI.BUTTON_WIDTH)
          .height(UI.BUTTON_HEIGHT)
          .fontSize($r('app.float.fp_button_font'))
          .backgroundColor(this.isDriving ? $r('app.color.danger') : $r('app.color.primary'))
          .borderRadius(UI.BUTTON_RADIUS)
          .scale({ x: this.scaleValue, y: this.scaleValue })
          .onClick(() => {
            this.isDriving ? this.stopDrive() : this.startDrive()
          })

        Text($r('app.string.view_history'))
          .fontSize($r('app.float.fp_text'))
          .fontColor($r('app.color.link'))
          .margin({ top: UI.MARGIN_TOP_LINK })

        Divider()

        Text($r('app.string.version'))
          .fontSize($r('app.float.fp_version_font'))
          .fontColor($r('app.color.version'))
          .margin({ bottom: UI.MARGIN_BOTTOM_VERSION })
      }
      .width(UI.FULL_WIDTH)
      .height(UI.FULL_HEIGHT)
      .backgroundColor($r('app.color.background'))
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .onBackPressed(() => {
      this.pageStack.disableAnimation(true)
      this.pageStack.replacePathByName('Index',false)
      return true
    })
    .hideTitleBar(true)
    .width(ConstantUI.FULL_WIDTH)
    .height(ConstantUI.FULL_HEIGHT)
  }
  pageTransition() {
    PageTransitionEnter({ type: RouteType.Push, duration: 400 }).slide(SlideEffect.Right)
    PageTransitionEnter({ type: RouteType.Pop, duration: 400 }).slide(SlideEffect.Left)
    PageTransitionExit({ type: RouteType.Push, duration: 400 }).slide(SlideEffect.Left)
    PageTransitionExit({ type: RouteType.Pop, duration: 400 }).slide(SlideEffect.Right)
  }
}

@Builder
export function IndexPageBuilder() {
  Index()
}
