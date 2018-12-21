// @author Tom van Roozendaal

String fileName = "001.jpg";
PImage img;
PImage pixelated;
int pixelFactor = 16; // nrof pixels (squared) turned into 1

void setup() {
  size(1024, 512);
  img = loadImage(fileName);
  //img.filter(GRAY);
  pixelated = createImage(ceil(img.width * 1.0/ pixelFactor), ceil(img.height * 1.0/ pixelFactor), RGB);
  image(img, 0, 0);
  noLoop();
}

void draw() {
  img.loadPixels();
  pixelated.loadPixels();

  pixelateImage(pixelFactor);
  
  // update and show the image
  img.updatePixels();
  pixelated.updatePixels();
  pixelated.save("data/" + fileName + "_" + pixelFactor + "pp.png");
  image(img, 512, 0);
  //image(pixelated, 512, 0);
}

/**
 * Image indices conversion methods
 */
int index(int x, int y) {
  return x + y * img.width;
}

int pIndex(int x, int y) {
  return x + y * pixelated.width;
}

void pixelateImage(int f) {
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
