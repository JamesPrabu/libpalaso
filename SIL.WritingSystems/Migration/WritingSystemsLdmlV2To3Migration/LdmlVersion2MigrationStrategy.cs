﻿using System;
using System.IO;
using System.Linq;
using System.Xml;
using System.Xml.Linq;
using Palaso.Migration;
using Palaso.Xml;
using SIL.WritingSystems.Migration.WritingSystemsLdmlV0To1Migration;

namespace SIL.WritingSystems.Migration.WritingSystemsLdmlV2To3Migration
{
	/// <summary>
	/// This class is used to migrate an LdmlFile from LDML palaso version 2 to 3. 
	/// V2 should be using BCP47 tags so no need for post-migration steps
	/// </summary>
	class LdmlVersion2MigrationStrategy : MigrationStrategyBase
	{
		public LdmlVersion2MigrationStrategy() :
			base(2, 3)
		{
		}

		public override void Migrate(string sourceFilePath, string destinationFilePath)
		{
			var writingSystemDefinitionV1 = new WritingSystemDefinitionV1();
			new LdmlAdaptorV1().Read(sourceFilePath, writingSystemDefinitionV1);

			// Remove legacy palaso namespace from sourceFilePath
			XElement ldmlElem = XElement.Load(sourceFilePath);
			ldmlElem.Elements("special").Where(e => !string.IsNullOrEmpty((string)e.Attribute(XNamespace.Xmlns + "palaso"))).Remove();
			ldmlElem.Elements("special").Where(e => !string.IsNullOrEmpty((string)e.Attribute(XNamespace.Xmlns + "palaso2"))).Remove();

			// Remove empty collations and collations that contain special
			ldmlElem.Elements("collations")
				.Elements("collation")
				.Where(e => e.IsEmpty || (string.IsNullOrEmpty((string) e) && !e.HasElements && !e.HasAttributes))
				.Remove();
			ldmlElem.Elements("collations").Elements("collation").Where(e => e.Descendants("special") != null).Remove();

			var writerSettings = CanonicalXmlSettings.CreateXmlWriterSettings();
			writerSettings.NewLineOnAttributes = false;
			using (var writer = XmlWriter.Create(sourceFilePath, writerSettings))
			{
				ldmlElem.WriteTo(writer);
				writer.Close();
			}

			var writingSystemDefinitionV3 = new WritingSystemDefinitionV3
			{
				Abbreviation = writingSystemDefinitionV1.Abbreviation,
				Keyboard = writingSystemDefinitionV1.Keyboard,
				LanguageName = writingSystemDefinitionV1.LanguageName,
				RightToLeftScript = writingSystemDefinitionV1.RightToLeftScript,

				VersionDescription = writingSystemDefinitionV1.VersionDescription,
				DateModified = DateTime.Now
				// TODO: reconcile these attributes
#if WS_FIX
				//DefaultFontName = writingSystemDefinitionV1.DefaultFontName,
				//DefaultFontSize = writingSystemDefinitionV1.DefaultFontSize,
#endif
			};

			// Convert sort rules to collation definition of standard type
			CollationDefinition cd;
			switch (writingSystemDefinitionV1.SortUsing)
			{
				case WritingSystemDefinitionV1.SortRulesType.CustomSimple:
					cd = new SimpleCollationDefinition("standard") { SimpleRules = writingSystemDefinitionV1.SortRules };
					break;
				case WritingSystemDefinitionV1.SortRulesType.OtherLanguage:
					cd = new InheritedCollationDefinition("standard") { BaseLanguageTag = writingSystemDefinitionV1.Bcp47Tag, BaseType = "standard"};
					break;
				case WritingSystemDefinitionV1.SortRulesType.CustomICU:
					cd = new CollationDefinition("standard") { IcuRules = writingSystemDefinitionV1.SortRules };
					break;
				default:
					cd = new CollationDefinition("standard");
					break;
			}
			writingSystemDefinitionV3.Collations.Add(cd);

			// Convert spell checking Id
			if (!string.IsNullOrEmpty(writingSystemDefinitionV1.SpellCheckingId))
			{
				var sd = new SpellCheckDictionaryDefinition(writingSystemDefinitionV1.SpellCheckingId.Replace("_", "-"),
					SpellCheckDictionaryFormat.Hunspell);
				writingSystemDefinitionV3.SpellCheckDictionary = sd;
			}

			writingSystemDefinitionV3.SetAllComponents(
				writingSystemDefinitionV1.Language,
				writingSystemDefinitionV1.Script,
				writingSystemDefinitionV1.Region,
				writingSystemDefinitionV1.Variant);

			using (Stream sourceStream = new FileStream(sourceFilePath, FileMode.Open))
			{
				var ldmlDataMapper = new LdmlAdaptorV3();
				ldmlDataMapper.Write(destinationFilePath, writingSystemDefinitionV3, sourceStream);
			}
		}
	}
}