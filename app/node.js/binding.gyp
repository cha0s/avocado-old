{
  'target_defaults': {
    'defines': [
      'AVOCADO_NODE'
    ],
    'cflags!': [ '-fno-exceptions', '-fno-rtti' ],
    'cflags_cc!': [ '-fno-exceptions', '-fno-rtti' ],
    'libraries': [
      '-lboost_filesystem',
      '-lboost_regex',
      '-lboost_system',
      '-lboost_program_options',
    ],
    'include_dirs': [
      '../native',
      '../native/deps',
    ],
    "sources": [
      "../native/SPI/Script/v8/avocado-v8.cpp",
      "../native/SPI/Script/v8/ObjectWrap.cpp"
    ]
  },
  "targets": [
    {
      "target_name": "Core",
      "sources": [
        "../native/FS.cpp",
        "../native/SPI/Script/v8/v8CoreService.cpp",
        "../native/SPI/Core/CoreService.cpp",
      ]
    },
    {
      "target_name": "Graphics",
      "sources": [
        "../native/SPI/Graphics/Font.cpp",
        "../native/SPI/Script/v8/v8Font.cpp",
        "../native/SPI/Graphics/GraphicsService.cpp",
        "../native/SPI/Script/v8/v8GraphicsService.cpp",
        "../native/SPI/Graphics/Image.cpp",
        "../native/SPI/Script/v8/v8Image.cpp",
        "../native/SPI/Graphics/Window.cpp",
        "../native/SPI/Script/v8/v8Window.cpp",
      ]
    },
    {
      "target_name": "Sound",
      "sources": [
        "../native/SPI/Script/v8/v8SoundService.cpp",
        "../native/SPI/Sound/SoundService.cpp",
        "../native/SPI/Script/v8/v8Music.cpp",
        "../native/SPI/Sound/Music.cpp",
        "../native/SPI/Script/v8/v8Sample.cpp",
        "../native/SPI/Sound/Sample.cpp",
      ]
    },
    {
      "target_name": "Timing",
      "sources": [
        "../native/SPI/Script/v8/v8TimingService.cpp",
        "../native/SPI/Timing/TimingService.cpp",
        "../native/SPI/Script/v8/v8Counter.cpp",
        "../native/SPI/Timing/Counter.cpp",
      ]
    }
  ]
}
