import controlP5.*;

PImage img;
String word = "";
int wordSize = 14;
float density = 0.5; // Menor valor para mayor densidad
ControlP5 cp5;
String imgPath = "";
PImage modifiedImg;
PImage imageToSave; // Variable global para almacenar la imagen a guardar
boolean windowOpen = false;
ArrayList<Integer> effects = new ArrayList<>(); // Almacena los efectos aplicados

void setup() {
  size(800, 400);
  cp5 = new ControlP5(this);

  setupUI(); // Configurar la interfaz de usuario

  textAlign(CENTER, CENTER);
  textSize(wordSize);
  background(200);
}

void draw() {
  // draw se deja vacío ya que el redibujado se hace en el botón de redibujar
}

// Configuración de la UI
void setupUI() {
  // Botón para seleccionar imagen
  cp5.addButton("selectImage")
    .setLabel("Seleccionar Imagen")
    .setPosition(50, 50)
    .setSize(150, 30);

  // Campo de texto para introducir el texto
  cp5.addTextfield("inputText")
    .setLabel("Texto a colocar")
    .setPosition(50, 100)
    .setSize(150, 30)
    .setAutoClear(false)
    .setText("")
    .onChange(new CallbackListener() {
      public void controlEvent(CallbackEvent event) {
        word = event.getController().getStringValue();
      }
    })
    .getCaptionLabel().set("Texto a colocar");

  // Botón para redibujar la imagen
  cp5.addButton("redrawImage")
    .setLabel("Redibujar Imagen")
    .setPosition(50, 150)
    .setSize(150, 30)
    .onClick(new CallbackListener() {
      public void controlEvent(CallbackEvent event) {
        redrawImage();
      }
    });

  // Texto para mostrar la ruta de la imagen seleccionada
  cp5.addTextlabel("imagePathLabel")
    .setPosition(50, 200)
    .setSize(700, 30)
    .setColorValue(0)
    .setText("Ruta de la imagen seleccionada: " + imgPath);
}

// Selección de imagen
void selectImage() {
  selectInput("Selecciona una imagen para redibujar:", "imageSelected");
}

// Imagen seleccionada
void imageSelected(File selection) {
  if (selection == null) {
    println("No se seleccionó ninguna imagen.");
  } else {
    imgPath = selection.getAbsolutePath();
    img = loadImage(imgPath);
    if (img != null) {
      img.resize(800, 800);
      img.loadPixels();
      cp5.get(Textlabel.class, "imagePathLabel").setText("Ruta de la imagen seleccionada: " + imgPath);
      println("Imagen seleccionada: " + imgPath);
    }
  }
}

// Redibujar imagen con el texto
void redrawImage() {
  if (img == null) {
    println("Primero selecciona una imagen.");
    return;
  }
  
  if (word.equals("")) {
    println("Primero introduce un texto.");
    return;
  }

  float aspectRatio = (float) img.width / img.height;
  int newWidth = (int) (800 * 0.8);
  int newHeight = (int) (newWidth / aspectRatio);

  PGraphics pg = createGraphics(newWidth, newHeight);
  pg.beginDraw();
  pg.background(255);
  pg.textSize(wordSize);
  
  // Dibujar el texto sobre la imagen
  for (float y = 0; y < img.height; y += wordSize * density) {
    for (float x = 0; x < img.width; x += wordSize * density) {
      int pixelColor = img.get(int(x), int(y));
      pg.fill(pixelColor);
      pg.text(word.charAt(int(random(word.length()))), x * newWidth / (float) img.width, y * newHeight / (float) img.height);
    }
  }

  pg.endDraw();
  modifiedImg = pg.get();

  if (!windowOpen) {
    openNewWindow(newWidth, newHeight); // Abrir nueva ventana para mostrar la imagen redibujada
  }
}

// Abrir nueva ventana para mostrar y aplicar efectos
void openNewWindow(int w, int h) {
  windowOpen = true;
  
  PApplet newWindow = new PApplet() {
    ControlP5 newCp5;
    PImage currentImg;
    PGraphics pg;
    
    public void settings() {
      size(w + 200, h); // Incrementar el ancho de la ventana para los controles
    }
    
    public void setup() {
      newCp5 = new ControlP5(this);
      currentImg = modifiedImg.copy();
      
      setupNewWindowUI(w, h); // Configurar la interfaz de usuario de la nueva ventana
      updateImage(); // Actualizar la imagen con los efectos aplicados
    }
    
    public void draw() {
      image(currentImg, 0, 0); // Mostrar imagen actualizada
    }

    // Configuración de la UI de la nueva ventana
    void setupNewWindowUI(int w, int h) {
      // Menú de efectos
      newCp5.addDropdownList("effects")
        .setPosition(w + 20, 20)
        .setSize(150, 150)
        .setOpen(true) // Mantener la lista de efectos abierta
        .addItem("None", 0)
        .addItem("Desenfoque", 1)
        .addItem("Escala de Grises", 2)
        .addItem("Invertir Colores", 3)
        .addItem("Sepia", 4)
        .addItem("Dibujo a Mano", 5)
        .addItem("Desenfoque Gaussiano", 6)
        .addItem("Ruido", 7)
        .setValue(0)
        .onChange(new CallbackListener() {
          public void controlEvent(CallbackEvent event) {
            int selectedEffect = (int) event.getController().getValue();
            if (selectedEffect == 0) {
              effects.clear(); // Limpiar los efectos si se selecciona "None"
              currentImg = modifiedImg.copy();
            } else if (!effects.contains(selectedEffect)) {
              effects.add(selectedEffect); // Añadir efecto seleccionado a la lista de efectos
            }
            updateImage(); // Actualizar la imagen con los efectos aplicados
          }
        });

      // Slider para ajustar la densidad
      newCp5.addSlider("density")
        .setPosition(w + 20, 140)
        .setSize(150, 20)
        .setRange(0.1, 1.0)
        .setValue(density)
        .setLabel("Densidad")
        .onChange(new CallbackListener() {
          public void controlEvent(CallbackEvent event) {
            density = event.getController().getValue();
            redrawImage(); // Redibujar la imagen con la nueva densidad
            updateImage(); // Actualizar la imagen con los efectos aplicados
          }
        });

      // Slider para ajustar el tamaño de la letra
      newCp5.addSlider("wordSize")
        .setPosition(w + 20, 180)
        .setSize(150, 20)
        .setRange(1, 50)
        .setValue(wordSize)
        .setLabel("Tamaño de la Letra")
        .onChange(new CallbackListener() {
          public void controlEvent(CallbackEvent event) {
            wordSize = int(event.getController().getValue());
            redrawImage(); // Redibujar la imagen con el nuevo tamaño de letra
            updateImage(); // Actualizar la imagen con los efectos aplicados
          }
        });

      // Botón para descargar la imagen
      newCp5.addButton("downloadImage")
        .setLabel("Descargar Imagen")
        .setPosition(w + 20, 220)
        .setSize(150, 30)
        .onClick(new CallbackListener() {
          public void controlEvent(CallbackEvent event) {
            imageToSave = currentImg.copy(); // Copiar la imagen actual para guardar
            downloadImage(); // Descargar la imagen
          }
        });
    }
    
    // Actualizar la imagen con efectos aplicados
    void updateImage() {
      pg = createGraphics(currentImg.width, currentImg.height);
      pg.beginDraw();
      pg.image(modifiedImg, 0, 0);
      pg.textSize(wordSize);
      applyEffects(pg); // Aplicar efectos a la imagen
      pg.endDraw();
      currentImg = pg.get();
    }

    // Aplicar efectos seleccionados en orden
    void applyEffects(PGraphics pg) {
      for (int effect : effects) {
        switch(effect) {
          case 1:
            pg.filter(BLUR, 3); // Efecto de desenfoque
            break;
          case 2:
            pg.filter(GRAY); // Efecto de escala de grises
            break;
          case 3:
            pg.filter(INVERT); // Efecto de invertir colores
            break;
          case 4:
            applySepia(pg); // Efecto sepia
            break;
          case 5:
            applyPosterize(pg); // Efecto dibujo a mano
            break;
          case 6:
            pg.filter(BLUR, 10); // Efecto de desenfoque gaussiano
            break;
          case 7:
            applyNoise(pg); // Efecto ruido
            break;
        }
      }
    }

    // Efecto Sepia
    void applySepia(PGraphics pg) {
      pg.loadPixels();
      for (int i = 0; i < pg.pixels.length; i++) {
        int c = pg.pixels[i];
        float r = red(c) * 0.393 + green(c) * 0.769 + blue(c) * 0.189;
        float g = red(c) * 0.349 + green(c) * 0.686 + blue(c) * 0.168;
        float b = red(c) * 0.272 + green(c) * 0.534 + blue(c) * 0.131;
        pg.pixels[i] = color(min(255, r), min(255, g), min(255, b));
      }
      pg.updatePixels();
    }

    // Efecto Dibujo a Mano
    void applyPosterize(PGraphics pg) {
      pg.filter(POSTERIZE, 5);
    }

    // Efecto Ruido
    void applyNoise(PGraphics pg) {
      pg.loadPixels();
      for (int i = 0; i < pg.pixels.length; i++) {
        int c = pg.pixels[i];
        float n = random(-50, 50);
        float r = red(c) + n;
        float g = green(c) + n;
        float b = blue(c) + n;
        pg.pixels[i] = color(min(255, max(0, r)), min(255, max(0, g)), min(255, max(0, b)));
      }
      pg.updatePixels();
    }
  };
  
  String[] args = { "" };
  PApplet.runSketch(args, newWindow);
}

// Descargar la imagen generada
void downloadImage() {
  if (imageToSave != null) {
    String outputFilePath = sketchPath("imageToSave.png");
    imageToSave.save(outputFilePath);
    println("Imagen guardada en: " + outputFilePath);
  }
}
