// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

import "../utils/Context.sol";

abstract contract ArticleService is Context {
	event ArticlePublished(uint256 articleNumber, address publisher);
	event ArticleUpdated(uint256 articleNumber);

	enum ArticleScope {
		UNLISTED,
		LISTED
	}

	struct Article {
		uint256 number;
		uint16 version;
		address publisher;
		string contentHash;
		ArticleScope scope;
		uint256 createdAt;
		uint256 updatedAt;
	}

	mapping(uint256 => Article) internal articles;

	uint256 internal articleGlobalIndex = 1;

	modifier verifyArticleOwnership(uint256 _articleNumber) {
		require(articles[_articleNumber].publisher == _msgSender());
		_;
	}

	modifier validateContentHash(string memory _contentHash) {
		require(bytes(_contentHash).length > 0);
		_;
	}

	modifier validateArticleNumber(uint256 _articleNumber) {
		require(_articleNumber > 0 && _articleNumber < articleGlobalIndex, "Incorrect article number");
		_;
	}

	/**
	 * @dev Upgrade metadata(including `version` and `updatedAt`) of article by `_articleNumber`
	 */
	function _upgradeMetadataOfArticle(uint256 _articleNumber) internal {
		uint16 newVersion = articles[_articleNumber].version + 1;

		require(newVersion <= 65535, "Article version exceeds limit");
		articles[_articleNumber].version = newVersion;
		articles[_articleNumber].updatedAt = block.timestamp;
	}

	/**
	 * @dev Get article by specified `_articleNumber`
	 */
	function getArticle(uint256 _articleNumber) public view returns(Article memory) {
		return articles[_articleNumber];
	}
}
