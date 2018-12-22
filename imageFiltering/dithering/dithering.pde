// Tom van Roozendaal as a modification to Daniel Shiffman's CC #90: Floyd-Steinberg dithering

String fileName = "003.jpg";
PImage img;
int pixelFactor = 4; // nrof pixels (squared) turned into 1
int quantizationFactor = 8;
int mode = 3;
int w, h;

// animation control
boolean loop = true;
int p = 1;
boolean b = true;

void setup() {
  size(1024, 1024);
  w = width;
  h = height;
  img = loadImage(fileName);
  //noLoop();
  frameRate(4);
}

void draw() {
  if ( p < 12 && b) {
    p++;
  } else if (p == 12) {
    b = false; 
    p--;
  } else if (p > 3 && !b) {
    p--;
  } else if (p == 3) {
    b = true; 
    p++;
  } 
  translate(w/2, w/2);
  // image 1
  img = loadImage(fileName);
  image(img, -w/2, -h/2);

  // image 2
  img.loadPixels();
  PImage pixelated = pixelateImage(img, p);
  ditherImage(pixelated, 8, 1);
  pixelated = resizeImage(pixelated, w/2, h/2);
  img.updatePixels();
  image(pixelated, 0, -h/2);

  // image 3
  img = loadImage(fileName);
  img.loadPixels();
  img = pixelateImage(img, 4);
  ditherImage(img, 2, 0);
  img = resizeImage(img, w/2, h/2);
  //pixelateImage(pixelFactor);
  img.updatePixels();
  image(img, -w/2, 0);

  // image 4
  img = loadImage(fileName);
  img.loadPixels();
  img = pixelateImage(img, 4);
  ditherImage(img, 6, 0);
  img = resizeImage(img, w/2, h/2);
  img.updatePixels();
  image(img, 0, 0);
}
// ----------------------------------
void mouseClicked() {
  loop = !loop;
  if (!loop ) { 
    noLoop();
  } else { 
    loop();
  };
}
// -------------------------------------------------------------------

/**
 * Image indices conversion methods
 */
int index(PImage img, int x, int y) {
  return x + y * img.width;
}

float[] quantizeArray(float[] a, int f) {
  f--;
  float[] b = new float[a.length];
  for (int i = 0; i < a.length; i++) {
    b[i] = round(f * a[i] / 255) * (255/f);
  }
  return b;
}

/**
 * Returns average color from the list of colors.
 */
public color avgColor(ArrayList l) {
  int r = 0;
  int g = 0;
  int b = 0;
  for (int i = 0; i < l.size(); i++) {
    color col = (color)l.get(i);
    r += red(col);
    g += green(col);
    b += blue(col);
  }
  return color(r/l.size(), g/l.size(), b/l.size());
}

PImage pixelateAndResizeImage(PImage img, int f) {
  int w = img.width;
  int h = img.height;
  img = pixelateImage(img, f);
  return resizeImage(img, w, h);
}

PImage pixelateImage(PImage img, int f) {
  PImage pixelated = createImage(ceil(img.width * 1.0/ f), ceil(img.height * 1.0/ f), RGB);
  pixelated.loadPixels();
  for (int y = 0; y < img.height; y += f) {
    for (int x = 0; x < img.width; x += f) {

      // get colors from a group of pixels
      ArrayList<Integer> colorList = new ArrayList<Integer>();
      int leftX = min(f, img.width - x);
      int leftY = min(f, img.height - y);
      for (int i = 0; i < leftX; i++) {
        for (int j = 0; j < leftY; j++) {
          colorList.add(img.pixels[index(img, x + i, y + j)]);
        }
      }

      // get the avg color from the group of pixels
      color c = avgColor(colorList);
      int pIndex = index(pixelated, (int)(x/f), (int)(y/f));
      pixelated.pixels[pIndex] = c;
    }
  }

  pixelated.updatePixels();
  return pixelated;
}

PImage resizeImage(PImage old, int w, int h) {
  old.loadPixels();
  PImage newImg  = createImage(w, h, RGB);
  newImg.loadPixels();
  for (int y = 0; y < newImg.height; y++) {
    for (int x = 0; x < newImg.width; x++) {
      int ox = int(map(x, 0, newImg.width, 0, old.width));
      int oy = int(map(y, 0, newImg.height, 0, old.height));
      color c = old.pixels[index(old, ox, oy)];
      newImg.pixels[index(newImg, x, y)] = c;
    }
  }
  newImg.updatePixels();
  return newImg;
}

void quantizeImage(PImage img, int f) {
  quantizeImage(img, f, 0);
}
void quantizeImage(PImage img, int f, int m) {
  img.loadPixels();
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      color pix = img.pixels[index(img, x, y)];
      // quantize
      float[] oldC = {red(pix), green(pix), blue(pix)};
      float[] newC = quantizeArray(oldC, f);

      float r = newC[0];
      float g = newC[1];
      float b = newC[2];
      img.pixels[index(img, x, y)] = colorFromMode(r, g, b, m);
    }
  }
  img.updatePixels();
}

void ditherImage(PImage img, int f) {
  ditherImage(img, f, 0);
}
void ditherImage(PImage img, int f, int m) {
  img.loadPixels();
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      color pix = img.pixels[index(img, x, y)];
      // quantize
      float[] oldC = {red(pix), green(pix), blue(pix)};
      float[] newC = quantizeArray(oldC, f);
      img.pixels[index(img, x, y)] = color(newC[0], newC[1], newC[2]);

      float[] err = new float[3];
      for (int i = 0; i< err.length; i++) {
        err[i] = oldC[i] - newC[i];
      }

      // Floyd-Steinberg dither
      int[] indices = {
        index(img, x+1, y), // right
        index(img, x-1, y+1), // bottom-left
        index(img, x, y+1), // bottom
        index(img, x+1, y+1)  // bottom-right
      };
      float[] factors = {
        7/16.0, 
        3/16.0, 
        5/16.0, 
        1/16.0
      };
      for (int i = 0; i < indices.length; i++) {
        if ( indices[i] < img.pixels.length ) {
          color c = img.pixels[indices[i]];

          float r = red(c);
          float g = green(c);
          float b = blue(c);
          r = r + err[0] * factors[i];
          g = g + err[1] * factors[i];
          b = b + err[2] * factors[i];
          img.pixels[indices[i]] = colorFromMode(r, g, b, m);
        }
      }
    }
  }
  img.updatePixels();
}

color colorFromMode(float r, float g, float b, int m) {
  switch (m) {
  case 1:  
    return color((r + g + b)/3, (r + g + b)/3, (r + g + b)/3);
  case 2:  
    return color((r + g) * 0.5, (r + g) * 0.5, b);
  case 3:  
    return color((r + b) * 0.5, g, (r + b) * 0.5);
  case 4:  
    return color(r, (g + b) * 0.5, (g + b) * 0.5);
  default: 
    return color(r, g, b);
  }
}
