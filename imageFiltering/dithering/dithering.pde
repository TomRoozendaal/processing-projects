// Tom van Roozendaal as a modification to Daniel Shiffman's CC #90: Floyd-Steinberg dithering

String fileName = "001.jpg";
PImage img;
PImage pixelated;
int pixelFactor = 4; // nrof pixels (squared) turned into 1
int quantizationFactor = 8;
int mode = 3;

void setup() {
  size(1024, 1024);
  img = loadImage(fileName);
  image(img, 0, 0);
  noLoop();
}

void draw() {
  img.loadPixels();
  quantizeImage(quantizationFactor, 2);
  //pixelateImage(pixelFactor);
  img.updatePixels();
  image(img, 512, 0);

  img = loadImage(fileName);
  img.loadPixels();
  pixelateImage(pixelFactor);
  quantizeImage(quantizationFactor, 3);
  img.updatePixels();
  image(img, 512, 512);

  img = loadImage(fileName);
  img.loadPixels();
  ditherImage(quantizationFactor, 4);
  //pixelateImage(pixelFactor);
  img.updatePixels();
  image(img, 0, 512);
}

// -------------------------------------------------------------------

/**
 * Image indices conversion methods
 */
int index(int x, int y) {
  return x + y * img.width;
}

int pIndex(int x, int y) {
  return x + y * pixelated.width;
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

void pixelateImage(int f) {
  pixelated = createImage(ceil(img.width * 1.0/ f), ceil(img.height * 1.0/ f), RGB);
  pixelated.loadPixels();
  for (int y = 0; y < img.height; y += f) {
    for (int x = 0; x < img.width; x += f) {

      // get colors from a group of pixels
      ArrayList<Integer> colorList = new ArrayList<Integer>();
      int leftX = min(f, img.width - x);
      int leftY = min(f, img.height - y);
      for (int i = 0; i < leftX; i++) {
        for (int j = 0; j < leftY; j++) {
          colorList.add(img.pixels[index(x + i, y + j)]);
        }
      }

      // get the avg color from the group of pixels
      color c = avgColor(colorList);
      int pIndex = pIndex((int)(x/f), (int)(y/f));
      pixelated.pixels[pIndex] = c;
      for (int i = 0; i < leftX; i++) {
        for (int j = 0; j < leftY; j++) {
          img.pixels[index(i + x, j + y)] = c;
        }
      }
    }
  }
  pixelated.updatePixels();
}

void quantizeImage(int f) {
  quantizeImage(f, 0);
}
void quantizeImage(int f, int m) {
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      color pix = img.pixels[index(x, y)];
      // quantize
      float[] oldC = {red(pix), green(pix), blue(pix)};
      float[] newC = quantizeArray(oldC, f);

      float r = newC[0];
      float g = newC[1];
      float b = newC[2];
      img.pixels[index(x, y)] = colorFromMode(r, g, b, m);
    }
  }
}

void ditherImage(int f) {
  ditherImage(f, 0);
}
void ditherImage(int f, int m) {
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      color pix = img.pixels[index(x, y)];
      // quantize
      float[] oldC = {red(pix), green(pix), blue(pix)};
      float[] newC = quantizeArray(oldC, f);
      img.pixels[index(x, y)] = color(newC[0], newC[1], newC[2]);

      float[] err = new float[3];
      for (int i = 0; i< err.length; i++) {
        err[i] = oldC[i] - newC[i];
      }

      // Floyd-Steinberg dither
      int[] indices = {
        index(x+1, y), // right
        index(x-1, y+1), // bottom-left
        index(x, y+1), // bottom
        index(x+1, y+1)  // bottom-right
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
