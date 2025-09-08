import lottie, { AnimationItem } from '@ohos/lottie'


@Component
export default struct LottieAnimation {
  @Prop politeChickyPath: string
  @Prop to?: string

  private canvasController: CanvasRenderingContext2D = new CanvasRenderingContext2D()
  private animationName: string = 'politeChicky'
  private animateItem: AnimationItem | null = null

  build() {
    Canvas(this.canvasController)
      .onReady(() => {
        this.animateItem = lottie.loadAnimation({
          container: this.canvasController,
          renderer: 'canvas',
          loop: true,
          autoplay: true,
          name: this.animationName,
          contentMode: 'Contain',
          path: this.politeChickyPath
        })

        if (this.to) {
          const onAnimationComplete = () => {
            this.animateItem?.destroy()
            this.animateItem?.removeEventListener('complete', onAnimationComplete)
          }
          this.animateItem?.addEventListener('complete', onAnimationComplete)
        }
      })
      .onDisAppear(() => {
        this.animateItem?.destroy()
      })
  }

  aboutToDisappear(): void {
    this.animateItem?.destroy()
  }
}
