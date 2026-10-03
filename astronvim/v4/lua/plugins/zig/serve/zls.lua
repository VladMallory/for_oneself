-- ZLS: включаем build-on-save, чтобы ошибки типа
-- "no field named 'name' in struct" подсвечивались в редакторе,
-- а не только при `zig run`.
-- Без этого ZLS показывает только ast-check, который такие ошибки не ловит
-- (проверено: `zig ast-check main.zig` молчит, `zig build-exe -fno-emit-bin` — ловит).
-- Важно: build-on-save работает только если у проекта есть build.zig.
-- Если в build.zig есть шаг "check", ZLS подхватит его сам.
-- См. https://zigtools.org/zls/guides/build-on-save/
-- NB: опции `build_on_save_step` в ZLS 0.15/0.16 нет (сверено со schema.json),
-- есть только `enable_build_on_save` и `build_on_save_args`.
-- Поэтому явно задаём только `enable_build_on_save`, выбор шага
-- ("check" в приоритете, иначе "install") оставляем самому ZLS.
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
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
