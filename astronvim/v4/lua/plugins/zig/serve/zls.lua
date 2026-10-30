-- ZLS: включаем build-on-save, чтобы ошибки типов/семантики
-- ("no field named 'name' in struct", "expected type ... found ...")
-- подсвечивались в редакторе, а не только при `zig build`/`zig test`.
--
-- Почему это нужно: сам ZLS умеет только ast-check (синтаксис) и пару
-- style-проверок. Полноценный semantic analysis делает компилятор Zig,
-- поэтому ZLS запускает `zig build` и публикует его ошибки как диагностику.
--
-- Требования к проекту:
--   1. в корне есть build.zig;
--   2. в build.zig объявлен шаг "check" (ZLS предпочитает его шагу install);
--   3. если нужны ошибки из `test "..." { ... }`, шаг "check" должен
--      зависеть ещё и от `b.addTest(...)` — иначе тесты не компилируются.
--
-- Для нового проекта это создаётся командой `zig init`.
-- См. https://zigtools.org/zls/guides/build-on-save/
--
-- `build_on_save_args` не нужен: при наличии шага "check" ZLS выбирает его сам.
-- Явный `servers = { "zls" }` нужен, чтобы ZLS запускался даже без пакета zls
-- в Mason (например, если zls установлен системно и лежит в PATH).
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    servers = { "zls" },
    config = {
      zls = {
        settings = {
          zls = {
            enable_build_on_save = true,
          },
        },
      },
    },
  },
}
