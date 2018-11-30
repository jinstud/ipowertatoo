#import <Foundation/Foundation.h>
#import "ImageScrollView.h"

@interface ImageScrollView ()

@property (nonatomic) CGSize imageSize;

@end

@implementation ImageScrollView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.imageView.frame;
    
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    } else {
        frameToCenter.origin.x = 0;
    }
    
    if (frameToCenter.size.height < boundsSize.height - self.heightOffset) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2 - self.heightOffset / 2;
    } else {
        frameToCenter.origin.y = 0;
    }
    
    self.imageView.frame = frameToCenter;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)setImage:(UIImage *)image {
    if (self.imageView) {
        [self.imageView removeFromSuperview];
        self.imageView = nil;
    }
    
    self.zoomScale = 1.0;

    self.imageView = [[UIImageView alloc] initWithImage:image];
    [self addSubview:self.imageView];
    
    [self configureForImageSize:image.size];
}

- (void)configureForImageSize:(CGSize)imageSize {
    self.imageSize = imageSize;
    self.contentSize = imageSize;
    [self setMaxMinZoomScalesForCurrentBounds];
    self.zoomScale = self.minimumZoomScale;
}

- (void)setMaxMinZoomScalesForCurrentBounds {
    CGSize boundsSize = self.bounds.size;
    
    CGFloat xScale = boundsSize.width  / self.imageSize.width;
    CGFloat yScale = boundsSize.height / self.imageSize.height;
    
    CGFloat minScale = MIN(xScale, yScale);
    CGFloat maxScale = 1.0 / [[UIScreen mainScreen] scale];
    
    if (minScale > maxScale) {
        minScale = maxScale;
    }
        
    self.maximumZoomScale = maxScale * 2;
    self.minimumZoomScale = minScale;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

/*- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    CGPoint pointInView = [recognizer locationInView:self.imageView];
    CGFloat newZoomScale;
    
    if (self.zoomScale >= self.maximumZoomScale / 2) {
        newZoomScale = self.minimumZoomScale;
    } else {
        newZoomScale = self.maximumZoomScale / 2;
    }
    
    CGSize scrollViewSize = self.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);

    [self zoomToRect:rectToZoomTo animated:YES];
}*/

@end
