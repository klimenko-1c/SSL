﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда // Возврат при получении формы для анализа.
		Возврат;
	КонецЕсли;
		
	Ключ = "";
	Для Каждого Предупреждение Из Параметры.Предупреждения Цикл
		Ключ = Ключ + Предупреждение.ДействиеПриУстановленномФлажке.Форма + Предупреждение.ДействиеПриНажатииГиперссылки.Форма;
	КонецЦикла;
	
	КлючСохраненияПоложенияОкна = "ПредупрежденияПриЗавершенииРаботы" + ОбщегоНазначения.КонтрольнаяСуммаСтрокой(Ключ);
	
	ИнициализироватьЭлементыВФорме(Параметры.Предупреждения);
	СтандартныеПодсистемыСервер.УстановитьОтображениеЗаголовковГрупп(ЭтотОбъект);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура Подключаемый_НажатиеНаГиперссылку(Элемент)
	ИмяЭлемента = Элемент.Имя;
	
	Для Каждого СтрокаВопроса Из МассивСоотношенияЭлементовИПараметров Цикл
		ПараметрыВопроса = Новый Структура("Имя, Форма, ПараметрыФормы");
		
		ЗаполнитьЗначенияСвойств(ПараметрыВопроса, СтрокаВопроса.Значение);
		Если ИмяЭлемента = ПараметрыВопроса.Имя Тогда 
			
			Если ПараметрыВопроса.Форма <> Неопределено Тогда
				ОткрытьФорму(ПараметрыВопроса.Форма, ПараметрыВопроса.ПараметрыФормы, ЭтотОбъект);
			КонецЕсли;
			
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте 
Процедура Подключаемый_ФлажокПриИзменении(Элемент)
	
	ИмяЭлемента      = Элемент.Имя;
	НайденныйЭлемент = Элементы.Найти(ИмяЭлемента);
	
	Если НайденныйЭлемент = Неопределено Тогда 
		Возврат;
	КонецЕсли;
	
	ЗначениеЭлемента = ЭтотОбъект[ИмяЭлемента];
	Если ТипЗнч(ЗначениеЭлемента) <> Тип("Булево") Тогда
		Возврат;
	КонецЕсли;

	ИдентификаторМассива = ИдентификаторМассиваЗадачПоИмени(ИмяЭлемента);
	Если ИдентификаторМассива = Неопределено Тогда 
		Возврат;
	КонецЕсли;
	
	ЭлементМассива = МассивЗадачНаВыполнениеПослеЗакрытия.НайтиПоИдентификатору(ИдентификаторМассива);
	
	Использование = Неопределено;
	Если ЭлементМассива.Значение.Свойство("Использование", Использование) Тогда 
		Если ТипЗнч(Использование) = Тип("Булево") Тогда 
			ЭлементМассива.Значение.Использование = ЗначениеЭлемента;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Завершить(Команда)
	
	ВыполнениеЗадачПриЗакрытии();
	
КонецПроцедуры

&НаКлиенте
Процедура Отмена(Команда)
	
	Закрыть(Истина);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Создает элементы формы по передаваемым вопросам пользователю.
//
// Параметры:
//     Вопросы - Массив - структуры с параметрами значений вопросов.
//                        См. СтандартныеПодсистемы.БазоваяФункциональность\ПередЗавершениемРаботыСистемы.
//
&НаСервере
Процедура ИнициализироватьЭлементыВФорме(Знач Предупреждения)
	
	// Добавляем возможно не указанные значения по умолчанию.
	ТаблицаПредупреждений = МассивСтруктурВТаблицуЗначений(Предупреждения);
	
	Для Каждого ТекущееПредупреждение Из ТаблицаПредупреждений Цикл 
		
		// Элемент на форму добавляем только если указаны или текст для флага, или текст для Гиперссылки, но не одновременно.
		НужнаСсылка = Не ПустаяСтрока(ТекущееПредупреждение.ТекстГиперссылки);
		НуженФлаг   = Не ПустаяСтрока(ТекущееПредупреждение.ТекстФлажка);
		
		Если НужнаСсылка И НуженФлаг Тогда
			Продолжить;
			
		ИначеЕсли НужнаСсылка Тогда
			СоздатьГиперссылкуНаФорме(ТекущееПредупреждение);
			
		ИначеЕсли НуженФлаг Тогда
			СоздатьФлажокНаФорме(ТекущееПредупреждение);
			
		КонецЕсли;
		
	КонецЦикла;
	
	// Подвал.
	ТекстНадписи = НСтр("ru = 'Завершить работу с программой?'");
	
	ИмяНадписи    = ОпределитьИмяНадписиВФорме("НадписьВопроса");
	ГруппаНадписи = СформироватьГруппуЭлементовФормы();
	
	ЭлементПоясняющегоТекста = Элементы.Добавить(ИмяНадписи, Тип("ДекорацияФормы"), ГруппаНадписи);
	ЭлементПоясняющегоТекста.ВертикальноеПоложение = ВертикальноеПоложениеЭлемента.Низ;
	ЭлементПоясняющегоТекста.Заголовок             = ТекстНадписи;
	ЭлементПоясняющегоТекста.Высота                = 2;
	
КонецПроцедуры

&НаСервере
Функция МассивСтруктурВТаблицуЗначений(Знач Предупреждения)
	
	// Формируем таблицу, содержащую значения по умолчанию.
	ТаблицаПредупреждений = Новый ТаблицаЗначений;
	КолонкиПредупреждений = ТаблицаПредупреждений.Колонки;
	КолонкиПредупреждений.Добавить("ПоясняющийТекст");
	КолонкиПредупреждений.Добавить("ТекстФлажка");
	КолонкиПредупреждений.Добавить("ДействиеПриУстановленномФлажке");
	КолонкиПредупреждений.Добавить("ТекстГиперссылки");
	КолонкиПредупреждений.Добавить("ДействиеПриНажатииГиперссылки");
	КолонкиПредупреждений.Добавить("Приоритет");
	КолонкиПредупреждений.Добавить("ВывестиОдноПредупреждение");
	КолонкиПредупреждений.Добавить("РасширеннаяПодсказка");
	
	ОдиночныеПредупреждения = Новый Массив;
	
	Для Каждого ЭлементПредупреждения Из Предупреждения Цикл
		СтрокаТаблицы = ТаблицаПредупреждений.Добавить();
		ЗаполнитьЗначенияСвойств(СтрокаТаблицы, ЭлементПредупреждения);
		
		Если СтрокаТаблицы.ВывестиОдноПредупреждение = Истина Тогда
			ОдиночныеПредупреждения.Добавить(СтрокаТаблицы);
		КонецЕсли;
	КонецЦикла;
	
	// Если было хоть одно предупреждение, требующее очистки (ВывестиОдноПредупреждение = Истина) то очищаем остальные.
	Если ОдиночныеПредупреждения.Количество() > 0 Тогда
		ТаблицаПредупреждений = ТаблицаПредупреждений.Скопировать(ОдиночныеПредупреждения);
	КонецЕсли;
	
	// Чем больше приоритет, тем выше в списке выводится предупреждение.
	ТаблицаПредупреждений.Сортировать("Приоритет УБЫВ");
	
	Возврат ТаблицаПредупреждений;
КонецФункции

&НаСервере
Функция СформироватьГруппуЭлементовФормы()
	
	ИмяГруппы = ОпределитьИмяНадписиВФорме("ГруппаВФорме");
	
	Группа = Элементы.Добавить(ИмяГруппы, Тип("ГруппаФормы"), Элементы.ОсновнаяГруппа);
	Группа.Вид = ВидГруппыФормы.ОбычнаяГруппа;
	
	Группа.РастягиватьПоГоризонтали = Истина;
	Группа.ОтображатьЗаголовок      = Ложь;
	Группа.Отображение              = ОтображениеОбычнойГруппы.Нет;
	
	Возврат Группа; 
	
КонецФункции

&НаСервере
Процедура СоздатьГиперссылкуНаФорме(СтруктураВопроса)
	
	Группа = СформироватьГруппуЭлементовФормы();
	
	Если Не ПустаяСтрока(СтруктураВопроса.ПоясняющийТекст) Тогда 
		ИмяНадписи = ОпределитьИмяНадписиВФорме("НадписьВопроса");
		ТипНадписи = Тип("ДекорацияФормы");
		
		РодительНадписи = Группа;
		
		ЭлементПоясняющегоТекста = Элементы.Добавить(ИмяНадписи, ТипНадписи, РодительНадписи);
		ЭлементПоясняющегоТекста.Заголовок = СтруктураВопроса.ПоясняющийТекст;
	КонецЕсли;
	
	Если ПустаяСтрока(СтруктураВопроса.ТекстГиперссылки) Тогда
		Возврат;
	КонецЕсли;
	
	// Конструируем гиперссылку
	ИмяГиперссылки = ОпределитьИмяНадписиВФорме("НадписьВопроса");
	ТипГиперссылки = Тип("ДекорацияФормы");
	
	РодительГиперссылки = Группа;

	ЭлементГиперссылки = Элементы.Добавить(ИмяГиперссылки, ТипГиперссылки, РодительГиперссылки);
	ЭлементГиперссылки.Гиперссылка = Истина;
	ЭлементГиперссылки.Заголовок   = СтруктураВопроса.ТекстГиперссылки;
	ЭлементГиперссылки.УстановитьДействие("Нажатие", "Подключаемый_НажатиеНаГиперссылку");
	
	УстановитьРасширеннуюПодсказку(ЭлементГиперссылки, СтруктураВопроса);
	
	СтруктураОбработки = СтруктураВопроса.ДействиеПриНажатииГиперссылки;
	Если ПустаяСтрока(СтруктураОбработки.Форма) Тогда
		Возврат;
	КонецЕсли;
	ПараметрыОткрытияФормы = Новый Структура;
	ПараметрыОткрытияФормы.Вставить("Имя", ИмяГиперссылки);
	ПараметрыОткрытияФормы.Вставить("Форма", СтруктураОбработки.Форма);
	
	ПараметрыФормы = СтруктураОбработки.ПараметрыФормы;
	Если ПараметрыФормы = Неопределено Тогда 
		ПараметрыФормы = Новый Структура;
	КонецЕсли;
	ПараметрыФормы.Вставить("ЗавершениеРаботыПрограммы", Истина);
	ПараметрыОткрытияФормы.Вставить("ПараметрыФормы", ПараметрыФормы);
	
	МассивСоотношенияЭлементовИПараметров.Добавить(ПараметрыОткрытияФормы);
		
КонецПроцедуры

&НаСервере
Процедура СоздатьФлажокНаФорме(СтруктураВопроса)
	
	ЗначениеПоУмолчанию = Истина;
	Группа  = СформироватьГруппуЭлементовФормы();
	
	Если Не ПустаяСтрока(СтруктураВопроса.ПоясняющийТекст) Тогда
		ИмяНадписи = ОпределитьИмяНадписиВФорме("НадписьВопроса");
		ТипНадписи = Тип("ДекорацияФормы");
		
		РодительНадписи = Группа;
		
		ЭлементПоясняющегоТекста = Элементы.Добавить(ИмяНадписи, ТипНадписи, РодительНадписи);
		ЭлементПоясняющегоТекста.Заголовок = СтруктураВопроса.ПоясняющийТекст;
	КонецЕсли;
	
	Если ПустаяСтрока(СтруктураВопроса.ТекстФлажка) Тогда 
		Возврат;
	КонецЕсли;
	
	// Добавляем реквизита в форму.
	ИмяФлажка = ОпределитьИмяНадписиВФорме("НадписьВопроса");
	ТипФлажка = Тип("ПолеФормы");
	
	РодительФлажка = Группа;
	
	МассивТипов = Новый Массив;
	МассивТипов.Добавить(Тип("Булево"));
	Описание = Новый ОписаниеТипов(МассивТипов);
	
	ДобавляемыеРеквизиты = Новый Массив;
	НовыйРеквизит = Новый РеквизитФормы(ИмяФлажка, Описание, , ИмяФлажка, Ложь);
	ДобавляемыеРеквизиты.Добавить(НовыйРеквизит);
	ИзменитьРеквизиты(ДобавляемыеРеквизиты);
	ЭтотОбъект[ИмяФлажка] = ЗначениеПоУмолчанию;
	
	НовоеПолеФормы = Элементы.Добавить(ИмяФлажка, ТипФлажка, РодительФлажка);
	НовоеПолеФормы.ПутьКДанным = ИмяФлажка;
	
	НовоеПолеФормы.ПоложениеЗаголовка = ПоложениеЗаголовкаЭлементаФормы.Право;
	НовоеПолеФормы.Заголовок          = СтруктураВопроса.ТекстФлажка;
	НовоеПолеФормы.Вид                = ВидПоляФормы.ПолеФлажка;
	
	УстановитьРасширеннуюПодсказку(НовоеПолеФормы, СтруктураВопроса);
	
	Если ПустаяСтрока(СтруктураВопроса.ДействиеПриУстановленномФлажке.Форма) Тогда
		Возврат;	
	КонецЕсли;
	
	СтруктураДействия = СтруктураВопроса.ДействиеПриУстановленномФлажке;
	
	НовоеПолеФормы.УстановитьДействие("ПриИзменении", "Подключаемый_ФлажокПриИзменении");
	
	ПараметрыОткрытияФормы = Новый Структура;
	ПараметрыОткрытияФормы.Вставить("Имя", ИмяФлажка);
	ПараметрыОткрытияФормы.Вставить("Форма", СтруктураДействия.Форма);
	ПараметрыОткрытияФормы.Вставить("Использование", ЗначениеПоУмолчанию);
	
	ПараметрыФормы = СтруктураДействия.ПараметрыФормы;
	Если ПараметрыФормы = Неопределено Тогда 
		ПараметрыФормы = Новый Структура;
	КонецЕсли;
	ПараметрыФормы.Вставить("ЗавершениеРаботыПрограммы", Истина);
	ПараметрыОткрытияФормы.Вставить("ПараметрыФормы", ПараметрыФормы);
	
	МассивЗадачНаВыполнениеПослеЗакрытия.Добавить(ПараметрыОткрытияФормы);
	
КонецПроцедуры

&НаСервере
Процедура УстановитьРасширеннуюПодсказку(ЭлементФормы, Знач СтрокаОписания)
	
	ОписаниеРасширеннойПодсказки = СтрокаОписания.РасширеннаяПодсказка;
	Если ОписаниеРасширеннойПодсказки = "" Тогда
		Возврат;
	КонецЕсли;
	
	Если ТипЗнч(ОписаниеРасширеннойПодсказки) <> Тип("Строка") Тогда
		// Устанавливаем в расширенную подсказку.
		ЗаполнитьЗначенияСвойств(ЭлементФормы.РасширеннаяПодсказка, ОписаниеРасширеннойПодсказки);
		ЭлементФормы.ОтображениеПодсказки = ОтображениеПодсказки.Кнопка;
		Возврат;
	КонецЕсли;
	
	ЭлементФормы.РасширеннаяПодсказка.Заголовок = ОписаниеРасширеннойПодсказки;
	ЭлементФормы.ОтображениеПодсказки = ОтображениеПодсказки.Кнопка;
	
КонецПроцедуры

&НаСервере
Функция ОпределитьИмяНадписиВФорме(ЗаголовокЭлемента)
	Индекс = 0;
	ФлагПоиска = Истина;
	
	Пока ФлагПоиска Цикл 
		ИндексСтрока = Строка(Формат(Индекс, "ЧН=-"));
		ИндексСтрока = СтрЗаменить(ИндексСтрока, "-", "");
		Имя = ЗаголовокЭлемента + ИндексСтрока;
		
		НайденныйЭлемент = Элементы.Найти(Имя);
		Если НайденныйЭлемент = Неопределено Тогда 
			Возврат Имя;
		КонецЕсли;
		
		Индекс = Индекс + 1;
	КонецЦикла;
КонецФункции	

&НаКлиенте
Функция ИдентификаторМассиваЗадачПоИмени(ИмяЭлемента)
	Для Каждого ЭлементМассива Из МассивЗадачНаВыполнениеПослеЗакрытия Цикл
		Наименование = "";
		Если ЭлементМассива.Значение.Свойство("Имя", Наименование) Тогда 
			Если Не ПустаяСтрока(Наименование) И Наименование = ИмяЭлемента Тогда
				Возврат ЭлементМассива.ПолучитьИдентификатор();
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Неопределено;
КонецФункции

&НаКлиенте
Процедура ВыполнениеЗадачПриЗакрытии(Результат = Неопределено, НачальныйНомерЗадачи = Неопределено) Экспорт
	
	Если НачальныйНомерЗадачи = Неопределено Тогда
		НачальныйНомерЗадачи = 0;
	КонецЕсли;
	
	Для НомерЗадачи = НачальныйНомерЗадачи По МассивЗадачНаВыполнениеПослеЗакрытия.Количество() - 1 Цикл
		
		ЭлементМассива = МассивЗадачНаВыполнениеПослеЗакрытия[НомерЗадачи];
		Использование = Неопределено;
		Если Не ЭлементМассива.Значение.Свойство("Использование", Использование) Тогда 
			Продолжить;
		КонецЕсли;
		Если ТипЗнч(Использование) <> Тип("Булево") Тогда 
			Продолжить;
		КонецЕсли;
		Если Использование <> Истина Тогда 
			Продолжить;
		КонецЕсли;
		
		Форма = Неопределено;
		Если ЭлементМассива.Значение.Свойство("Форма", Форма) Тогда 
			ПараметрыФормы = Неопределено;
			Если ЭлементМассива.Значение.Свойство("ПараметрыФормы", ПараметрыФормы) Тогда 
				Оповещение = Новый ОписаниеОповещения("ВыполнениеЗадачПриЗакрытии", ЭтотОбъект, НомерЗадачи + 1);
				ОткрытьФорму(Форма, СтруктураИзФиксированнойСтруктуры(ПараметрыФормы),,,,,Оповещение, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
				Возврат;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	Закрыть(Ложь);
	
КонецПроцедуры

&НаКлиенте
Функция СтруктураИзФиксированнойСтруктуры(Источник)
	
	Результат = Новый Структура;
	
	Для Каждого Элемент Из Источник Цикл
		Результат.Вставить(Элемент.Ключ, Элемент.Значение);
	КонецЦикла;
	
	Возврат Результат;
КонецФункции

#КонецОбласти
