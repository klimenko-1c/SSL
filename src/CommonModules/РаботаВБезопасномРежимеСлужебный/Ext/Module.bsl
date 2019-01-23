﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

// Проверяет возможность настройки профилей безопасности из текущей информационной базы.
//
// Возвращаемое значение: 
//   Булево - Истина, если настройка доступна.
//
Функция ДоступнаНастройкаПрофилейБезопасности() Экспорт
	
	Если ВозможноИспользованиеПрофилейБезопасности() Тогда
		
		Отказ = Ложь;
		
		ИнтеграцияСТехнологиейСервиса.ПриПроверкеВозможностиНастройкиПрофилейБезопасности(Отказ);
		Если Не Отказ Тогда
			РаботаВБезопасномРежимеПереопределяемый.ПриПроверкеВозможностиНастройкиПрофилейБезопасности(Отказ);
		КонецЕсли;
		
		Возврат Не Отказ;
		
	Иначе
		
		Возврат Ложь;
		
	КонецЕсли;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Внешние модули
//

// Возвращает режим подключения внешнего модуля.
//
// Параметры:
//  ВнешнийМодуль - ЛюбаяСсылка, ссылка, соответствующая внешнему модулю, для которого запрашиваются
//    режим подключения.
//
// Возвращаемое значение: Строка - имя профиля безопасности, который должен использоваться для подключения
//  внешнего модуля. Если для внешнего модуля не зарегистрирован режим подключения - возвращается Неопределено.
//
Функция РежимПодключенияВнешнегоМодуля(Знач ВнешнийМодуль) Экспорт
	
	Возврат РегистрыСведений.РежимыПодключенияВнешнихМодулей.РежимПодключенияВнешнегоМодуля(ВнешнийМодуль);
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Использование профилей безопасности.
//

// Возвращает URI пространства имен XDTO-пакета, который используется для описания разрешений
// в профилях безопасности.
//
// Возвращаемое значение: Строка, URI пространства имен XDTO-пакета.
//
Функция Пакет() Экспорт
	
	Возврат Метаданные.ПакетыXDTO.ApplicationPermissions_1_0_0_2.ПространствоИмен;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Создание запросов разрешений.
//

// Создает запросы на использование внешних ресурсов для внешнего модуля.
//
// Параметры:
//  ВнешнийМодуль - ЛюбаяСсылка - ссылка, соответствующая внешнему модулю, для которого запрашиваются разрешения,
//  НовыеРазрешения - Массив(ОбъектXDTO) - массив ОбъектовXDTO, соответствующих внутренним описаниям
//    запрашиваемых разрешений на доступ к внешним ресурсам. Предполагается, что все ОбъектыXDTO, передаваемые
//    в качестве параметра, сформированы с помощью вызова функций РаботаВБезопасномРежиме.Разрешение*().
//    При запросе разрешений для внешних модулей добавление разрешений всегда выполняется в режиме замещения.
//
// Возвращаемое значение - Массив(УникальныйИдентификатор) - идентификаторы созданных запросов.
//
Функция ЗапросРазрешенийДляВнешнегоМодуля(Знач ПрограммныйМодуль, Знач НовыеРазрешения = Неопределено) Экспорт
	
	Результат = Новый Массив();
	
	Если НовыеРазрешения = Неопределено Тогда
		НовыеРазрешения = Новый Массив();
	КонецЕсли;
	
	Если НовыеРазрешения.Количество() > 0 Тогда
		
		// Если профиля безопасности еще нет - его требуется создать.
		Если РежимПодключенияВнешнегоМодуля(ПрограммныйМодуль) = Неопределено Тогда
			Результат.Добавить(ЗапросСозданияПрофиляБезопасности(ПрограммныйМодуль));
		КонецЕсли;
		
		Результат.Добавить(
			ЗапросИзмененияРазрешений(
				ПрограммныйМодуль, Истина, НовыеРазрешения, Неопределено, ПрограммныйМодуль));
		
	Иначе
		
		// Если профиль безопасности есть - его требуется удалить.
		Если РежимПодключенияВнешнегоМодуля(ПрограммныйМодуль) <> Неопределено Тогда
			Результат.Добавить(ЗапросУдаленияПрофиляБезопасности(ПрограммныйМодуль));
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Использование профилей безопасности.
//

////////////////////////////////////////////////////////////////////////////////
// Преобразование ссылок к виду Тип+Идентификатор для хранения в регистрах
// разрешений.
//
// Используется нестандартный способ хранения ссылок т.к. для регистров разрешений не
// требуется обеспечение ссылочной целостности, и не требуется удаление записей из
// регистров вместе с удалением объекта.
//

// Формирует параметры для хранения ссылки в регистрах разрешений.
//
// Параметры:
//  Ссылка - ЛюбаяСсылка.
//
// Возвращаемое значение: Структура:
//                        * Тип - СправочникСсылка.ИдентификаторыОбъектовМетаданных,
//                        * Идентификатор - УникальныйИдентификатор - уникальный
//                           идентификатор ссылки.
//
Функция СвойстваДляРегистраРазрешений(Знач Ссылка) Экспорт
	
	Результат = Новый Структура("Тип,Идентификатор");
	
	Если Ссылка = Справочники.ИдентификаторыОбъектовМетаданных.ПустаяСсылка() Тогда
		
		Результат.Тип = Справочники.ИдентификаторыОбъектовМетаданных.ПустаяСсылка();
		Результат.Идентификатор = ОбщегоНазначенияКлиентСервер.ПустойУникальныйИдентификатор();
		
	Иначе
		
		Результат.Тип = ОбщегоНазначения.ИдентификаторОбъектаМетаданных(Ссылка.Метаданные());
		Результат.Идентификатор = Ссылка.УникальныйИдентификатор();
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Применение запросов разрешений на использование внешних ресурсов.
//

// Формирует представление разрешений на использование внешних ресурсов по таблицам разрешений.
//
// Параметры:
//  Таблицы - Структура - таблицы разрешений, для которых формируется представление
//    (см. ТаблицыРазрешений()).
//
// Возвращаемое значение: ТабличныйДокумент, представление разрешений на использование внешних ресурсов.
//
Функция ПредставлениеРазрешенийНаИспользованиеВнешнихРесурсов(Знач ТипПрограммногоМодуля, Знач ИдентификаторПрограммногоМодуля, Знач ТипВладельца, Знач ИдентификаторВладельца, Знач Разрешения) Экспорт
	
	// АПК:326-выкл Транзакция используется для того, чтобы использовать регистр сведений ЗапросыРазрешений
	// как промежуточный кэш для расчета применения запросов на разрешение использование внешних ресурсов.
	// отмена транзакции в данном случае используется как сигнал к очистке кэша расчетов.
	
	НачатьТранзакцию();
	Попытка
		Менеджер = Обработки.НастройкаРазрешенийНаИспользованиеВнешнихРесурсов.Создать();
		
		Менеджер.ДобавитьЗапросРазрешенийНаИспользованиеВнешнихРесурсов(
			ТипПрограммногоМодуля,
			ИдентификаторПрограммногоМодуля,
			ТипВладельца,
			ИдентификаторВладельца,
			Истина,
			Разрешения,
			Новый Массив());
		
		Менеджер.РассчитатьПрименениеЗапросов();
		
		ОтменитьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
	// АПК:326-вкл
	
	Возврат Менеджер.Представление(Истина);
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий подсистем конфигурации.

// См. ОбщегоНазначенияПереопределяемый.ПриДобавленииПараметровРаботыКлиентаПриЗапуске.
Процедура ПриДобавленииПараметровРаботыКлиентаПриЗапуске(Параметры, ДоОбновленияПараметровРаботыПрограммы = Ложь) Экспорт
	
	Если ДоОбновленияПараметровРаботыПрограммы Тогда
		Параметры.Вставить("ОтображатьПомощникНастройкиРазрешений", Ложь);
		Возврат;
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	
	Параметры.Вставить("ОтображатьПомощникНастройкиРазрешений", ИспользуетсяИнтерактивныйРежимЗапросаРазрешений());
	Если Не Параметры.ОтображатьПомощникНастройкиРазрешений Тогда
		Возврат;
	КонецЕсли;	
	
	Если Не Пользователи.ЭтоПолноправныйПользователь() Тогда
		Возврат;
	КонецЕсли;	
			
	Проверка = НастройкаРазрешенийНаИспользованиеВнешнихРесурсовВызовСервера.ПроверитьПрименениеРазрешенийНаИспользованиеВнешнихРесурсов();
	Если Проверка.РезультатПроверки Тогда
		Параметры.Вставить("ПроверитьПримененияРазрешенийНаИспользованиеВнешнихРесурсов", Ложь);
	Иначе
		Параметры.Вставить("ПроверитьПримененияРазрешенийНаИспользованиеВнешнихРесурсов", Истина);
		Параметры.Вставить("ПроверкаПримененияРазрешенийНаИспользованиеВнешнихРесурсов", Проверка);
	КонецЕсли;
	
КонецПроцедуры

// См. ВариантыОтчетовПереопределяемый.НастроитьВариантыОтчетов.
Процедура ПриНастройкеВариантовОтчетов(Настройки) Экспорт
	МодульВариантыОтчетов = ОбщегоНазначения.ОбщийМодуль("ВариантыОтчетов");
	МодульВариантыОтчетов.НастроитьОтчетВМодулеМенеджера(Настройки, Метаданные.Отчеты.ИспользуемыеВнешниеРесурсы);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Создает запрос на создание профиля безопасности для внешнего модуля.
// Только для внутреннего использования.
//
// Параметры:
//  ВнешнийМодуль - ЛюбаяСсылка - ссылка, соответствующая внешнему модулю, для которого запрашиваются
//    разрешения. (Неопределено при запросе разрешений для конфигурации, а не для внешних модулей).
//
// Возвращаемое значение - УникальныйИдентификатор - идентификатор созданного запроса.
//
Функция ЗапросСозданияПрофиляБезопасности(Знач ПрограммныйМодуль)
	
	СтандартнаяОбработка = Истина;
	Результат = Неопределено;
	Операция = Перечисления.ОперацииАдминистрированияПрофилейБезопасности.Создание;
	
	ИнтеграцияСТехнологиейСервиса.ПриЗапросеСозданияПрофиляБезопасности(
		ПрограммныйМодуль, СтандартнаяОбработка, Результат);
	
	Если СтандартнаяОбработка Тогда
		РаботаВБезопасномРежимеПереопределяемый.ПриЗапросеСозданияПрофиляБезопасности(
			ПрограммныйМодуль, СтандартнаяОбработка, Результат);
	КонецЕсли;
	
	Если СтандартнаяОбработка Тогда
		
		Результат = РегистрыСведений.ЗапросыРазрешенийНаИспользованиеВнешнихРесурсов.ЗапросАдминистрированияРазрешений(
			ПрограммныйМодуль, Операция);
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Использование профилей безопасности.
//

// Проверяет возможность использования профилей безопасности для текущей информационной базы.
//
// Возвращаемое значение: Булево.
//
Функция ВозможноИспользованиеПрофилейБезопасности() Экспорт
	
	Если ОбщегоНазначения.ИнформационнаяБазаФайловая(СтрокаСоединенияИнформационнойБазы()) Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Отказ = Ложь;
	
	РаботаВБезопасномРежимеПереопределяемый.ПриПроверкеВозможностиИспользованияПрофилейБезопасности(Отказ);
	
	Возврат Не Отказ;
	
КонецФункции

// Возвращает контрольные суммы файлов комплекта внешней компоненты, поставляемого в макете конфигурации.
//
// Параметры:
//  ИмяМакета - Строка - имя макета конфигурации, в составе которого поставляется комплект внешней компоненты.
//
// Возвращаемое значение - ФиксированноеСоответствие:
//                         * Ключ - Строка - имя файла,
//                         * Значение - Строка - контрольная сумма.
//
Функция КонтрольныеСуммыФайловКомплектаВнешнейКомпоненты(Знач ИмяМакета) Экспорт
	
	Результат = Новый Соответствие();
	
	СтруктураИмени = СтрРазделить(ИмяМакета, ".");
	
	Если СтруктураИмени.Количество() = 2 Тогда
		
		// Это общий макет
		Макет = ПолучитьОбщийМакет(СтруктураИмени[1]);
		
	ИначеЕсли СтруктураИмени.Количество() = 4 Тогда
		
		// Это макет объекта метаданных.
		МенеджерОбъекта = ОбщегоНазначения.МенеджерОбъектаПоПолномуИмени(СтруктураИмени[0] + "." + СтруктураИмени[1]);
		Макет = МенеджерОбъекта.ПолучитьМакет(СтруктураИмени[3]);
		
	Иначе
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось сформировать разрешение на использование внешней компоненты:
				  |некорректное имя макета %1.'"), ИмяМакета);
	КонецЕсли;
	
	Если Макет = Неопределено Тогда
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось сформировать разрешение на использование внешней компоненты,
				  |поставляемой в макете %1: макет %1 не обнаружен в составе конфигурации.'"), ИмяМакета);
	КонецЕсли;
	
	ТипМакета = Метаданные.НайтиПоПолномуИмени(ИмяМакета).ТипМакета;
	Если ТипМакета <> Метаданные.СвойстваОбъектов.ТипМакета.ДвоичныеДанные И ТипМакета <> Метаданные.СвойстваОбъектов.ТипМакета.ВнешняяКомпонента Тогда
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось сформировать разрешение на использование внешней компоненты:
				  |макет %1 не содержит двоичных данных.'"), ИмяМакета);
	КонецЕсли;
	
	ВременныйФайл = ПолучитьИмяВременногоФайла("zip");
	Макет.Записать(ВременныйФайл);
	
	Архиватор = Новый ЧтениеZipФайла(ВременныйФайл);
	КаталогРаспаковки = ПолучитьИмяВременногоФайла() + "\";
	СоздатьКаталог(КаталогРаспаковки);
	
	ФайлМанифеста = "";
	Для Каждого ЭлементАрхива Из Архиватор.Элементы Цикл
		Если ВРег(ЭлементАрхива.Имя) = "MANIFEST.XML" Тогда
			ФайлМанифеста = КаталогРаспаковки + ЭлементАрхива.Имя;
			Архиватор.Извлечь(ЭлементАрхива, КаталогРаспаковки);
		КонецЕсли;
	КонецЦикла;
	
	Если ПустаяСтрока(ФайлМанифеста) Тогда
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось сформировать разрешение на использование внешней компоненты,
				  |поставляемой в макете %1: в архиве не обнаружен файл MANIFEST.XML.'"), ИмяМакета);
	КонецЕсли;
	
	ПотокЧтения = Новый ЧтениеXML();
	ПотокЧтения.ОткрытьФайл(ФайлМанифеста);
	ОписаниеКомплекта = ФабрикаXDTO.ПрочитатьXML(ПотокЧтения, ФабрикаXDTO.Тип("http://v8.1c.ru/8.2/addin/bundle", "bundle"));
	Для Каждого ОписаниеКомпоненты Из ОписаниеКомплекта.component Цикл
		
		Если ОписаниеКомпоненты.type = "native" ИЛИ ОписаниеКомпоненты.type = "com" Тогда
			
			ФайлКомпоненты = КаталогРаспаковки + ОписаниеКомпоненты.path;
			
			Архиватор.Извлечь(Архиватор.Элементы.Найти(ОписаниеКомпоненты.path), КаталогРаспаковки);
			
			Хэширование = Новый ХешированиеДанных(ХешФункция.SHA1);
			Хэширование.ДобавитьФайл(ФайлКомпоненты);
			
			ХэшСумма = Хэширование.ХешСумма;
			ХэшСуммаПреобразованнаяКСтрокеBase64 = Base64Строка(ХэшСумма);
			
			Результат.Вставить(ОписаниеКомпоненты.path, ХэшСуммаПреобразованнаяКСтрокеBase64);
			
		КонецЕсли;
		
	КонецЦикла;
	
	ПотокЧтения.Закрыть();
	Архиватор.Закрыть();
	
	Попытка
		УдалитьФайлы(КаталогРаспаковки);
	Исключение
		ЗаписьЖурналаРегистрации(НСтр("ru = 'Работа в безопасном режиме.Не удалось удалить временный файл'", ОбщегоНазначения.КодОсновногоЯзыка()), 
			УровеньЖурналаРегистрации.Ошибка, , , ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
	КонецПопытки;
	
	Попытка
		УдалитьФайлы(ВременныйФайл);
	Исключение
		ЗаписьЖурналаРегистрации(НСтр("ru = 'Работа в безопасном режиме.Не удалось удалить временный файл'", ОбщегоНазначения.КодОсновногоЯзыка()), 
			УровеньЖурналаРегистрации.Ошибка, , , ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
	КонецПопытки;
	
	Возврат Новый ФиксированноеСоответствие(Результат);
	
КонецФункции

// Формирует ссылку из данных, хранящихся в регистрах разрешений.
//
// Параметры:
//  Тип - СправочникСсылка.ИдентификаторОбъектаМетаданных,
//  Идентификатор - УникальныйИдентификатор - уникальный идентификатор ссылки.
//
// Возвращаемое значение: ЛюбаяСсылка.
//
Функция СсылкаИзРегистраРазрешений(Знач Тип, Знач Идентификатор) Экспорт
	
	Если Тип = Справочники.ИдентификаторыОбъектовМетаданных.ПустаяСсылка() Тогда
		Возврат Тип;
	КонецЕсли;
		
	ОбъектМетаданных = ОбщегоНазначения.ОбъектМетаданныхПоИдентификатору(Тип);
	Менеджер = ОбщегоНазначения.МенеджерОбъектаПоПолномуИмени(ОбъектМетаданных.ПолноеИмя());
	
	Если ПустаяСтрока(Идентификатор) Тогда
		Возврат Менеджер.ПустаяСсылка();
	Иначе
		Возврат Менеджер.ПолучитьСсылку(Идентификатор);
	КонецЕсли;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Создание запросов разрешений.
//

// Создает запрос на изменение разрешений использования внешних ресурсов.
// Только для внутреннего использования.
//
// Параметры:
//  Владелец - ЛюбаяСсылка - владелец разрешений на использование внешних ресурсов.
//    (Неопределено при запросе разрешений для конфигурации, а не для объектов конфигурации),
//  РежимЗамещения - Булево - режим замещения ранее предоставленных для владельца разрешений,
//  ДобавляемыеРазрешения - Массив(ОбъектXDTO) - массив ОбъектовXDTO, соответствующих внутренним описаниям
//    запрашиваемых разрешений на доступ к внешним ресурсам. Предполагается, что все ОбъектыXDTO, передаваемые
//    в качестве параметра, сформированы с помощью вызова функций РаботаВБезопасномРежиме.Разрешение*(),
//  УдаляемыеРазрешения - Массив(ОбъектXDTO) - массив ОбъектовXDTO, соответствующих внутренним описаниям
//    отменяемых разрешений на доступ к внешним ресурсам. Предполагается, что все ОбъектыXDTO, передаваемые
//    в качестве параметра, сформированы с помощью вызова функций РаботаВБезопасномРежиме.Разрешение*(),
//  ВнешнийМодуль - ЛюбаяСсылка - ссылка, соответствующая внешнему модулю, для которого запрашиваются
//    разрешения. (Неопределено при запросе разрешений для конфигурации, а не для внешних модулей).
//
// Возвращаемое значение - УникальныйИдентификатор - идентификатор созданного запроса.
//
Функция ЗапросИзмененияРазрешений(Знач Владелец, Знач РежимЗамещения, Знач ДобавляемыеРазрешения = Неопределено, Знач УдаляемыеРазрешения = Неопределено, Знач ПрограммныйМодуль = Неопределено) Экспорт
	
	СтандартнаяОбработка = Истина;
	Результат = Неопределено;
	
	ИнтеграцияСТехнологиейСервиса.ПриЗапросеРазрешенийНаИспользованиеВнешнихРесурсов(
			ПрограммныйМодуль, Владелец, РежимЗамещения, ДобавляемыеРазрешения, УдаляемыеРазрешения, СтандартнаяОбработка, Результат);
	
	Если СтандартнаяОбработка Тогда
		
		РаботаВБезопасномРежимеПереопределяемый.ПриЗапросеРазрешенийНаИспользованиеВнешнихРесурсов(
			ПрограммныйМодуль, Владелец, РежимЗамещения, ДобавляемыеРазрешения, УдаляемыеРазрешения, СтандартнаяОбработка, Результат);
		
	КонецЕсли;
	
	Если СтандартнаяОбработка Тогда
		
		Результат = РегистрыСведений.ЗапросыРазрешенийНаИспользованиеВнешнихРесурсов.ЗапросИспользованияРазрешений(
			ПрограммныйМодуль, Владелец, РежимЗамещения, ДобавляемыеРазрешения, УдаляемыеРазрешения);
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Создает запрос на удаление профиля безопасности для внешнего модуля.
// Только для внутреннего использования.
//
// Параметры:
//  ВнешнийМодуль - ЛюбаяСсылка - ссылка, соответствующая внешнему модулю, для которого запрашиваются
//    разрешения. (Неопределено при запросе разрешений для конфигурации, а не для внешних модулей).
//
// Возвращаемое значение - УникальныйИдентификатор - идентификатор созданного запроса.
//
Функция ЗапросУдаленияПрофиляБезопасности(Знач ПрограммныйМодуль) Экспорт
	
	СтандартнаяОбработка = Истина;
	Результат = Неопределено;
	Операция = Перечисления.ОперацииАдминистрированияПрофилейБезопасности.Удаление;
	
	ИнтеграцияСТехнологиейСервиса.ПриЗапросеУдаленияПрофиляБезопасности(
			ПрограммныйМодуль, СтандартнаяОбработка, Результат);
	
	Если СтандартнаяОбработка Тогда
		РаботаВБезопасномРежимеПереопределяемый.ПриЗапросеУдаленияПрофиляБезопасности(
			ПрограммныйМодуль, СтандартнаяОбработка, Результат);
	КонецЕсли;
	
	Если СтандартнаяОбработка Тогда
		
		Результат = РегистрыСведений.ЗапросыРазрешенийНаИспользованиеВнешнихРесурсов.ЗапросАдминистрированияРазрешений(
			ПрограммныйМодуль, Операция);
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Создает запросы на обновление разрешений конфигурации.
//
// Параметры:
//  ВключаяЗапросСозданияПрофиляИБ - Булево - включать в результат запрос на создание профиля безопасности
//    для текущей информационной базы.
//
// Возвращаемое значение: 
//   Массив Из УникальныйИдентификатор - идентификаторы запросов для обновления разрешений
//                                       конфигурации до требуемых в настоящий момент.
//
Функция ЗапросыОбновленияРазрешенийКонфигурации(Знач ВключаяЗапросСозданияПрофиляИБ = Истина) Экспорт
	
	Результат = Новый Массив();
	
	НачатьТранзакцию();
	Попытка
		Если ВключаяЗапросСозданияПрофиляИБ Тогда
			Результат.Добавить(ЗапросСозданияПрофиляБезопасности(Справочники.ИдентификаторыОбъектовМетаданных.ПустаяСсылка()));
		КонецЕсли;
		
		ЗаполнитьРазрешенияНаЦентрЗащитыОбновлений(Результат);
		ИнтеграцияПодсистемБСП.ПриЗаполненииРазрешенийНаДоступКВнешнимРесурсам(Результат);
		РаботаВБезопасномРежимеПереопределяемый.ПриЗаполненииРазрешенийНаДоступКВнешнимРесурсам(Результат);
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
	Возврат Результат;
	
КонецФункции

Процедура ЗаполнитьРазрешенияНаЦентрЗащитыОбновлений(ЗапросыРазрешений)
	
	Разрешение = РаботаВБезопасномРежиме.РазрешениеНаИспользованиеИнтернетРесурса("HTTPS", "1cv8update.com",, 
		НСтр("ru = 'Сайт ""Центр защиты обновлений"" (ЦЗО) для проверки правомерности использования и обновления программного продукта.'"));
	Разрешения = Новый Массив;
	Разрешения.Добавить(Разрешение);
	ЗапросыРазрешений.Добавить(РаботаВБезопасномРежиме.ЗапросНаИспользованиеВнешнихРесурсов(Разрешения));

КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Прочее.
//

// Возвращает программный модуль, выполняющий функции менеджера внешнего модуля.
//
//  ВнешнийМодуль - ЛюбаяСсылка, ссылка, соответствующая внешнему модулю, для которого запрашиваются
//    менеджер.
//
// Возвращаемое значение: ОбщийМодуль.
//
Функция МенеджерВнешнегоМодуля(Знач ВнешнийМодуль) Экспорт
	
	Менеджеры = МенеджерыВнешнихМодулей();
	Для Каждого Менеджер Из Менеджеры Цикл
		КонтейнерыМенеджера = Менеджер.КонтейнерыВнешнихМодулей();
		
		Если ТипЗнч(ВнешнийМодуль) = Тип("СправочникСсылка.ИдентификаторыОбъектовМетаданных") Тогда
			ОбъектМетаданных = ОбщегоНазначения.ОбъектМетаданныхПоИдентификатору(ВнешнийМодуль);
		Иначе
			ОбъектМетаданных = ВнешнийМодуль.Метаданные();
		КонецЕсли;
		
		Если КонтейнерыМенеджера.Найти(ОбъектМетаданных) <> Неопределено Тогда
			Возврат Менеджер;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Неопределено;
	
КонецФункции

// Процедура должна вызываться при записи любых служебных данных, изменение которых должно быть
// недопустимо при установленном безопасном режиме.
//
Процедура ПриЗаписиСлужебныхДанных(Объект) Экспорт
	
	Если РаботаВБезопасномРежиме.УстановленБезопасныйРежим() Тогда
		
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Запись объекта %1 недоступна: установлен безопасный режим: %2.'"),
			Объект.Метаданные().ПолноеИмя(),
			БезопасныйРежим());
		
	КонецЕсли;
	
КонецПроцедуры

// Проверяет, требуется ли использовать интерактивный режим запроса разрешений.
//
// Возвращаемое значение: Булево.
//
Функция ИспользуетсяИнтерактивныйРежимЗапросаРазрешений()
	
	Если ВозможноИспользованиеПрофилейБезопасности() Тогда
		
		Возврат ПолучитьФункциональнуюОпцию("ИспользуютсяПрофилиБезопасности") И Константы.АвтоматическиНастраиватьРазрешенияВПрофиляхБезопасности.Получить();
		
	Иначе
		
		Возврат Ложь;
		
	КонецЕсли;
	
КонецФункции

// Возвращает массив менеджеров справочников, которые являются контейнерами внешних модулей.
//
// Возвращаемое значение: Массив(СправочникМенеджер).
//
Функция МенеджерыВнешнихМодулей()
	
	Менеджеры = Новый Массив;
	
	ИнтеграцияПодсистемБСП.ПриРегистрацииМенеджеровВнешнихМодулей(Менеджеры);
	
	Возврат Менеджеры;
	
КонецФункции

#КонецОбласти
