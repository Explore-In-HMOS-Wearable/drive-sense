import LottieAnimation from '../animation/LottieAnimation'
import { ConstantUI } from '../util/ConstantUI';
import { DetailPageBuilder } from './DetailPage';
import { HistoryPageBuilder } from './HistoryPage';
import { IndexPageBuilder } from './Index';

@Entry
@Component
export struct SplashPage {
  @Provide('NavPathStack') pageStack: NavPathStack = new NavPathStack()

  aboutToAppear() {
    setTimeout(() => {
      this.pageStack.replacePathByName('Index',null)
    }, 5000)
  }

  build() {
    Navigation(this.pageStack){
      Column() {
        LottieAnimation({ politeChickyPath: 'resources/rawfile/driving_center.json' })
          .width(ConstantUI.FULL_WIDTH)
          .height(ConstantUI.FULL_HEIGHT)
      }
      .width(ConstantUI.FULL_WIDTH)
      .height(ConstantUI.FULL_HEIGHT)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
    .width(ConstantUI.FULL_WIDTH)
    .height(ConstantUI.FULL_HEIGHT)
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .hideBackButton(true)
    .ignoreLayoutSafeArea()
    .navDestination(this.PageMap)
    .titleMode(NavigationTitleMode.Mini)
  }
  @Builder
  PageMap(name: string) {
    if (name === 'Index') {
      IndexPageBuilder()
    } else if (name === 'DetailPage') {
      DetailPageBuilder()
    } else if (name === 'HistoryPage') {
      HistoryPageBuilder()
    } else {

    }

  }

}
